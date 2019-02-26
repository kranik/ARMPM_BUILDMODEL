# Power Model generation for ARM big.LITTLE aka _ARMPM\_BUILDMODEL_

**September 2017 - The code is no loger actively maintained, though I have some plans for a possuble update on the multi-thread model methodology!**

**March 2018 - I have officially graduated, so this project is currently closed.**

**February 2019 - Project reopened due to interested from other academic parties.**

Full details about the methodology and the produced models are presented in the dissertation [_Power Modelling and Analysis on Heterogeneous Embedded Systems_](https://seis.bristol.ac.uk/~eejlny/downloads/kris_thesis.pdf).


## Getting Started

The scripts contained in this repo represent the second part of the power modelling and analysis methodology, that I have developed as part of my PhD, namely the offline model generation and analysis. They work with the on-platform data gathered by the [_ARMPM\_DATACOLLECT_](https://github.com/kranik/DATACOLLECT) scripts. 

The whole model generation and validation process takes multiple steps:
1. Run the [_ARMPM\_DATACOLLECT_](https://github.com/kranik/DATACOLLECT) on the platform and obtain PMU event and power sensor samples from the platform.
2. Concatenate all the data files using timestamps from the samples using [`XU3_results.sh`](Scripts/XU3_results.sh).
3. Analyse the concatenated data files using [`octave_makemodel.sh`](Scripts/octave_makemodel.sh)

The [`octave_makemodel.sh`](Scripts/octave_makemodel.sh) script does both the model generation and validaton in a two-step process, but within the same script.

### Prerequisites

### Installing

## Usage

### Troubleshooting

## Contributing

## Versioning

## Author

The work presented here was carried out by me, [Dr Kris Nikov](kris.nikov@bris.ac.uk) as part of my PhD project in the Department of Electrical and Electronic Enginnering at the Univeristy of Bristol,UK.

## Licence

This project is licensed under the BSD-3 License - please see [LICENSE.md](LICENSE.md) for more details.

## Acknowledgements

The primary project supervisor was [Dr Jose Nunez-Yanez](http://www.bristol.ac.uk/engineering/people/jose-l-nunez-yanez/overview.html). This work was initially supported by [ARM Research](https://www.arm.com/resources/research) funding, through an EPSRC iCASE studentship and the [University of Bristol](http://www.bristol.ac.uk/doctoral-college/) and by the EPSRC ENEAC grant number EP/N002539/1. Industrial project supervisor was [Dr Matt Horsnell](https://uk.linkedin.com/in/matthorsnell)
