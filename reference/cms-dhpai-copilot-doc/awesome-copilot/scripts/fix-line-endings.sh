#!/usr/bin/env bash
find . -type f -not -path "*/.git/*" -exec dos2unix {} +
