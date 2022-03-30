#!/bin/sh

grep -v -E '^#|^\[' packageList | yay -S --needed