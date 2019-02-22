# gomemcache
Simple memcache-like server written in Go

## Usage

Start up the server.

Connect on port 8080 via TCP (like with telnet for example).

**Commands:**

SET varname expires_in_sec value

GET varname

DEL varname

QUIT

## Background

I created this project for educational purposes for learning Go. So this server probably is not appropriate for production environments.

## Acknowledgements

This is an expansion of a simple server that is part of a course called ["Web Development w/ Google’s Go (golang) Programming Language"](https://www.udemy.com/go-programming-language/) taught by [Todd McLeod](https://github.com/GoesToEleven) (awesome course!).
