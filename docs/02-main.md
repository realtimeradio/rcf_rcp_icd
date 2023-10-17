# Introduction

This document defines the interface between the RCF (Radio-Camera Frontend) and RCP (Radio-Camera Processor) systems.
This interface is used to transfer high data rate ($\sim 10^{13}$ bits/s) digital, channelized voltages from all antennas in the DSA array to the RCP processing nodes.
Physical connectivity between RCF and RCP is provided by the SNW (Signal Network) subsystem, which is currently assumed to be a large ($\sim 1000$-port) 100 Gb/s Ethernet network.
As such, using the terminology of the OSI (open systems interconnection) model, this ICD concerns itself with communication layers 4 and higher.

## Data Description
Data carried by the RCF-RCP interface is made up of 4+4 bit complex voltage samples, with one sample per polarization and per antenna for each of the 2000 dual-polarization DSA antennas.
Voltage samples are transmitted for a variety of channelized data streams, and include:

1. $\sim 10000$ frequency channels, each with $\sim 130$ kHz bandwidth
2. $\sim 4096$ frequency channels, each with $\sim 8$ kHz bandwidth
3. $\sim 2048$ frequency channels, each with $\sim 1$ kHz bandwidth

The full data rate of the interface is $\sim 21.3$ Gbit/s per dual-polarization antenna, totalling $\sim 43$ Tbit/s for the full 2000-antenna array.

## Requirements & Motivations
### Requirements
1. The interface must be capable of carrying $\sim 20$ Gbits/s of data from each of 2000 dual-polarization DSA antennas from RCF to RCP.
2. The interface should support transmission \emph{from} RCF nodes each of which only has access to a single DSA dual-polarizion antenna data stream.
3. The interface should support transmission \emph{to} RCP nodes with each node receiving a multiple of 4 channels, forming a subset of the total transmitted channels.
4. Data transmitted via the interface should be self-describing in terms of the antenna indices, frequency-indices, and time-indices being sent.
5. The interface should contain meta-data allowing voltage samples transmitted to be related to a GPS time standard.
6. The interface should be supported by a 100 Gb Ethernet data link layer.

There is no requirement for the interface to support error-correction, or guaranteed delivery.

## Desirable Features
1. The RCF-RCP interface should be easily supported by both FPGA processors (at the RCF end) and CPU/GPU processors (at the RCP end).

# Interface Definition

The RCF-RCP interface is a stream of UDP/IPv4 packets, assumed to be transmitted over a 100 Gb Ethernet data link.

Each packet contains voltage samples from a subset of antennas, polarizations, frequency channels, and times, with a short meta-data header.

Parameters defining a packet are:

1. `N_CHAN` -- The number of contiguous frequency channels in a packet.
2. `N_TIME` -- The number of contiguous time samples in a packet.
3. `N_TIME_FINE` -- The number of contiguous time samples in the fastest changing axis of a packet payload.
4. `N_STATION` -- The number of contiguous (by index) stations in a packet.
5. `N_POLARIZATION` -- The number of polarizations (per station) in a packet.
6. `N_BIT` -- The number of bits per real/imaginary component of a single voltage sample. Limited to 4, or multiples of 8.

As a C-structure, the complete packet format is then:

``` c
struct rcf_rcp_packet {
    uint64_t time0
    uint16_t n_time
    uint16_t n_time_fine
    uint16_t n_chan
    uint16_t n_station
    uint8_t n_polarization
    uint8_t n_bit
    uint16_t chan0
    uint16_t station0
    uint8_t pol0
    uint8_t freq_mode
    uint64_t reserved
    char data[N_CHAN, N_TIME / N_TIME_FINE, N_STATION, N_POLARIZATION,
              N_TIME_FINE, N_BIT*2 / 8] };
```

Header entries have the following meanings:

1. `time0` -- The index of the first time sample in the packet, with index 0 corresponding to the sample taken at the UNIX epoch.
2. `chan0` -- The index of the first frequency channel in the packet.
3. `station0` -- The index of the first station in the packet.
4. `pol0` -- The index of the first polarization in the packet.
5. `freq_mode` -- A to-be-defined enumeration indicating whether the packet contains data from the 1 kHz, 8 kHz, or 130 kHz resolutions.
6. `reserved` -- Reserved bytes to be allocated in future revisions of the format.

Other header entries - `n_time`, `n_time_fine`, `n_chan`, `n_station`, `n_polarization`, and `n_bit` should hold the values `N_TIME`, `N_TIME_FINE`, `N_CHAN`, `N_STATION`, `N_POLARIZATION`, and `N_BIT`, respectively.

All header entries are transported in network- (i.e., big-) endian.

In the event that `N_BIT = 4`, each entry in the `data` payload is an 8 bit value with the 2's complement real part of the sample stored in the most significant 4-bits, and the 2's complement imaginary part of the sample stored in the least significant 4 bits.

In the event that `N_BIT = 8` (or larger) the `data` payload should be cast to the appropriate `N_BIT` signed data type to collapse the final axis of the array into two elements. After this process, the real part of samples are stored in index 0 of the final axis of the array, with the imaginary parts in index 1.
For `N_BIT > 8`, data payloads are transmitted in little-endian form.

## Allowable Parameters

The generic interface described above may be varied at runtime, but the following limitations are always met

1. `N_TIME` -- Must be a multiple of 8, $< 256$. Must be a multiple of `N_TIME_FINE`
2. `N_TIME_FINE` -- must be a power of 2
3. `N_CHAN` -- must be a multiple of 4
4. `N_STATION` -- receiver must support `N_STATION = 1`
5. `N_POLARIZATION` -- receiver must support `N_POLARIZATION = 2`
6. `N_BIT` -- Always 4, unless high-level system specifications are changed.

In addition, the product to `N_TIME`, `N_STATION`, `N_POLARIZATION`, `N_CHAN`, and `N_BIT` must be no greater than 32768 in order for a packet not to exceed a payload size of 8192 Bytes.
