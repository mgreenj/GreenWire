# Low-Latency Data Aggregator

## Table of Contents
- [Introduction](#introduction)
- [Blog](#blog)
- [Installing DPDK](#install-dpdk)
- [Build GreenWire Application](#application-setup)

## Introduction
This is a hobby project that will be used to demonstrate low-latency development with C.  I will use DPDK
to streamline the development process.

## Blog
I will [blog](https://blog.thecodeguardian.dev) throughout the development to discuss some of the more important or challenging optimizations.  I may include a few vlogs as well; if I do, the videos will be linked on my blog.

## Install DPDK
Follow the [instructions provided](docs/install.md) to install.

## Build GreenWire Application
Follow the [setup guide](docs/appsetup.md) provided.  Note that the setup script will build a local
environment for cross-compiling to the target triple `arch-linux-gnu` where arch is either `x86_64`, `mips`, or `arm`.  All testing was done for the following target triple: `x86_64-linux-gnu`.  If yours is different, you may have to troubleshoot.