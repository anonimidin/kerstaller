# Kerstaller - Kernel Installer

![GitHub last commit](https://img.shields.io/github/last-commit/anonimidin/kerstaller)

A Bash script for updating and installing Linux kernels on Ubuntu-based systems.

## Table of Contents
- [Introduction](#introduction)
- [Prerequisites](#prerequisites)
- [Usage](#usage)
- [Disclaimer](#disclaimer)

## Introduction

This script is designed to help you manage your Linux kernel on Ubuntu-based systems. It provides two main methods for kernel management:

1. **Method 1: Update Using HWE (Hardware Enablement Stack)**
   This method updates your kernel to the latest version available through HWE packages.

2. **Method 2: Install a Specific Kernel**
   This method allows you to install a custom kernel version and checks for known vulnerabilities associated with that version in the National Vulnerability Database (NVD).

## Prerequisites

- You must run this script as a superuser (root).

## Usage
```bash
sudo bash kerstaller.sh
```

### Option 1: Update Using HWE

This method updates your kernel to the latest version available through HWE packages.

### Option 2: Install a Specific Kernel (USE THIS OPTION WITH CAUTION!)

This method allows you to install a specific kernel version. It also checks for known vulnerabilities associated with that version in the National Vulnerability Database (NVD).

#### Peace.
