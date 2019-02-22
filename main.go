package main

import (
	"bufio"
	"fmt"
	"log"
	"net"
	"os"
	"runtime"
	"strconv"
	"strings"
	"sync"
	"time"
)

const debugging = false

// max bytes to allow this server to use
const maxMemUsage = 1000000000

// max lifetime of a cache key
const maxExpireSec = 86400 * 7

type memval struct {
	value   string
	expires time.Time
}

//	IN-MEMORY CACHE
//	USAGE:
//		SET key expires_in_sec value
//		GET key
//		DEL key
//		QUIT
//	EXAMPLE:
//		SET fav 60 chocolate
//		GET fav
//		QUIT

var cache = make(map[string]memval)
var mutex = &sync.Mutex{}
var shutdown = false

func main() {
	lf, lferr := os.OpenFile("gomemcache.log", os.O_APPEND|os.O_CREATE|os.O_WRONLY, 0644)
	if lferr != nil {
		log.Fatalln(lferr)
	}
	logger := log.New(lf, "", log.LstdFlags)

	li, err := net.Listen("tcp", ":8080")
	if err != nil {
		logger.Fatalln(err)
	}
	defer li.Close()
	defer func() { logger.Println("Shuttin' her down"); shutdown = true }()

	logger.Println("Server started")

	go cleaner(logger)

	for {
		conn, err := li.Accept()
		if err != nil {
			logger.Println(err)
			continue
		}
		go handle(conn, logger)
	}
}

func cleaner(logger *log.Logger) {
	if shutdown {
		logger.Println("Shutdown detected (1)")
		return
	}
	time.Sleep(time.Second * 60)
	if shutdown {
		logger.Println("Shutdown detected (2)")
		return
	}

	n := time.Now()
	logger.Println("Locking the cache while checking for expired keys")
	dcount := 0
	mutex.Lock() // need to lock it while we iterate
	for k, v := range cache {
		if v.expires.Before(n) {
			logger.Println("Cache key expired: " + k)
			delete(cache, k)
			dcount++
		}
	}
	logger.Println("Unlocking cache")
	mutex.Unlock()

	if dcount > 1 || !memUsageOk(logger) {
		// force garbage collection
		runtime.GC()
	}

	cleaner(logger)
}

func handle(conn net.Conn, logger *log.Logger) {
	defer conn.Close()
	ip := conn.RemoteAddr()
	debug(logger, ip, "Connection accepted")
	fmt.Fprintf(conn, "HI %s\r\n", ip.String())
	scanner := bufio.NewScanner(conn)
	closeconn := false
	for scanner.Scan() {
		ln := scanner.Text()
		fs := strings.SplitN(ln, " ", 3)
		if len(fs) < 1 {
			continue
		}
		cmd := strings.ToUpper(fs[0])
		switch cmd {
		case "GET":
			debug(logger, ip, "Handling command: "+cmd)
			if len(fs) < 2 {
				fmt.Fprintf(conn, "Invalid arguments for GET\r\n")
				break
			}
			k := fs[1]
			if v, ok := cache[k]; ok {
				mutex.Lock()
				if v.expires.Before(time.Now()) {
					warn(logger, ip, "Key expired: "+k)
					delete(cache, k)
					fmt.Fprintf(conn, "\r\n")
					mutex.Unlock()
					break
				}
				fmt.Fprintf(conn, "%s\r\n", v.value)
				mutex.Unlock()
			} else {
				warn(logger, ip, "Key does not exist: "+k)
				fmt.Fprintf(conn, "\r\n")
			}
		case "SET":
			debug(logger, ip, "Handling command: "+cmd)
			if !memUsageOk(logger) {
				warn(logger, ip, "SET command denied - memory full")
				fmt.Fprintln(conn, "MEMFULL")
				break
			}
			if len(fs) < 3 {
				fmt.Fprintf(conn, "Invalid arguments for SET\r\n")
				break
			}
			timeAndValue := strings.SplitN(fs[2], " ", 2)
			if len(timeAndValue) < 2 {
				fmt.Fprintf(conn, "Invalid arguments for SET\r\n")
				break
			}
			k := fs[1]
			e := timeAndValue[0]
			v := timeAndValue[1]
			ei := 300 // expires in 5 minutes by default
			if i, err := strconv.Atoi(e); err == nil {
				ei = i
				if ei == 0 || ei > maxExpireSec {
					ei = maxExpireSec // 30 days max
					warn(logger, ip, fmt.Sprintf("Changing key '%s' expiration for %d sec", k, ei))
				}
			}
			now := time.Now()
			exptime := now.Add(time.Second * time.Duration(ei))
			mutex.Lock()
			cache[k] = memval{value: v, expires: exptime}
			mutex.Unlock()
			fmt.Fprintf(conn, "OK\r\n")
		case "DEL":
			debug(logger, ip, "Handling command: "+cmd)
			k := fs[1]
			mutex.Lock()
			delete(cache, k)
			mutex.Unlock()
			fmt.Fprintf(conn, "OK\r\n")
		case "QUIT", "END", "EXIT":
			debug(logger, ip, "Handling command: "+cmd)
			fmt.Fprintln(conn, "BYE")
			closeconn = true
		default:
			debug(logger, ip, "Handling command: "+cmd)
			fmt.Fprintf(conn, "INVALID COMMAND %s\r\n", fs[0])
		}
		if closeconn {
			break
		}
	}
	debug(logger, ip, "Ending connection")
}

func memUsageOk(logger *log.Logger) bool {
	m := runtime.MemStats{}
	runtime.ReadMemStats(&m)
	if m.HeapInuse > maxMemUsage*0.75 {
		logger.Printf("[warn] Memory usage - %+v", m)
		if m.HeapInuse > maxMemUsage {
			logger.Printf("[CRITICAL] Using too much system memory: %d bytes", m.HeapInuse)
			return false
		}
	}
	return true
}

func logIt(l *log.Logger, ip net.Addr, m string) {
	l.Printf("[client: %s] %s", ip.String(), m)
}

func debug(l *log.Logger, ip net.Addr, m string) {
	if debugging {
		logIt(l, ip, "[debug] "+m)
	}
}

func warn(l *log.Logger, ip net.Addr, m string) {
	logIt(l, ip, "[warn] "+m)
}
