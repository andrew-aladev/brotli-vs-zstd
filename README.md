# Comparison of brotli and zstd

Please disable any performance boosts for your CPU and force base clock.
Tests will be executed in single thread mode to provide more accurate results.

# RAM usage

We are creating compressors and decompressors for each param combination.
All compressors and decompressors are sitting inside RAM together.
Each file passes through all processors.
Benchmark requires about 4 GB of free RAM.

## License

MIT license, see LICENSE and AUTHORS.
