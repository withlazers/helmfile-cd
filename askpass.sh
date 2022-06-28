#!/bin/sh -e
case "$1" in
    Username*) exec cat /auth/username ;;
    Password*) exec cat /auth/password ;;
esac
