
[![wakatime](https://wakatime.com/badge/github/mgreenj/GreenWire.svg)](https://wakatime.com/badge/github/mgreenj/GreenWire)
---
# Low-Latency Data Aggregator

## Table of Contents
- [Introduction](#introduction)
- [Blog](#blog)
- [Installing DPDK](#install-dpdk)
- [Build GreenWire Application](#application-setup)

## Introduction
GreenWire is an experimental high-performance networking project focused on building a low-latency data ingestion and aggregation pipeline suitable for HPC workflows. It incorporates a custom AF_XDP Poll Mode Driver written from scratch, using libbpf and raw sockets, designed to bypass the kernel stack for direct user-space packet processing. This driver integrates with DPDK-based components to pull large volumes of telemetry and observational data from high-speed sources.

A Django-based frontend allows users to input parameters and visualize real-time benchmarking results, while a performance analysis layer uses custom metrics to evaluate memory bandwidth, CPU usage, and DMA transfer characteristics.

The project aims to evaluate performance trade-offs between AF_XDP, DPDK, and traditional NIC drivers, as well as experiment with core pinning, zero-copy, and NUMA-aware memory allocation across multi-socket architectures.

## Blog
I will [blog](https://blog.thecodeguardian.dev) throughout the development to discuss some of the more important or challenging optimizations.  I may include a few vlogs as well; if I do, the videos will be linked on my blog.

## Install DPDK
Follow the [instructions provided](docs/install.md) to install.

## Build GreenWire Application
Follow the [setup guide](docs/appsetup.md) provided.  Note that the setup script will build a local
environment for cross-compiling to the target triple `arch-linux-gnu` where arch is either `x86_64`, `mips`, or `arm`.  All testing was done for the following target triple: `x86_64-linux-gnu`.  If yours is different, you may have to troubleshoot.
