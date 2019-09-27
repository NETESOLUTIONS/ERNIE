#!/usr/bin/env bash
grep -H --before-context=1 --after-context=2 ERROR **/errors.log
