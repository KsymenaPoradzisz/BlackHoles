# Visualization of black hole accretion flows in Julia
Written for Julia Version 1.10.5
## Description
This repository is dedicated to visualisation of black hole accretion flows in programming language Julia. However, while calculations are made using pure Julia, the visualisation process is coducted with supporting Python code. 

## Table of Contents
1. [Installation](#installation)
2. [Usage](#usage)
3. [Results](#results)

## Installation
0. Have python and julia installed https://docs.julialang.org/en/v1/manual/getting-started/ https://wiki.python.org/moin/BeginnersGuide/Download
1.  Have ```pip``` installed https://pip.pypa.io/en/stable/installation/
2. Clone the repo:
   ```bash
   git clone https://github.com/KsymenaPoradzisz/AccretionCurrentsJulia
   cd AccretionCurrentsJulia
   ```
4. Activate the project in Julia
   ```bash
   julia build_me.jl
   ```
    Above will install and compile required packages. It takes some time...
> [!WARNING]  
>  This is confirmed to work in Linux enviroment. Users of macOS might encounter problems. For macOS see below
   - Have Homebrew installed https://brew.sh/
   - Activate the project in Julia - for macOS
       ```bash
      julia build_me_macOS.jl
      ```
     
   
 
## Usage
### Obtaining visualisation for Schwarzschild black hole
1.Firstly, one have to generate data for flows. To do so, run: in terminal
```bash
 julia Schwarzschild.jl
```

Then insert values for beta, velocity and the radius of the area shown in animation. All these numbers should be passed as Float64/Int (so no 1/2, strings and etc). Remember that v should be inserted as a negative number and abs(v)<1.

2. After generating data one should have obtain a file named with a pattern: 'data\_Schw\_beta\_\$(β)\_v\_\$(v)\_dim\_\$(a_box)\_\$(timestamp_for_file).csv' in the working directory
3. To generate animation, run in terminal:
```bash
julia Visualisation.jl
```
There are two options of creating animations. One can do them with static streamlines or with dynamic (also called fading/vanishing) streamlines. Program wil ask you which one you want to obtain. 
- s - static;
- d - dynamic; 
- b - both.

4. When the code finish running you should obtain both *.mp4 and *.gif file with your visualisation. Enjoy :)

### Comparision between Schwarzschild metric accretion currents and Kerr metric accretion currents (with a = 0)

The default parameters are: beta = 2; v = -0.5.
For these parameters to obtain comparison, the following steps are needed:
1. In terminal run
   ```bash
   julia Kerr_comparison.jl
   julia Schwarzschild_comparison.jl
   ```
2. These should generate two files .csv in your directory - one for Kerr and one for Schwarzschild. Then run:
   ```bash
   julia comparison.jl
   ```
   This should generate 6 pictures of 2D histograms showing difference between calculated accretion integrals 

## Results
   
The result of Schwarzschild visualisation with dynamic streamlines is presented below


https://github.com/user-attachments/assets/49d63a47-c94f-412b-9e87-d7c8aff6d0b3

https://github.com/user-attachments/assets/55b7570f-65f7-47d1-97a1-01b5ba0305fd

https://github.com/user-attachments/assets/d0221ca4-1c3e-4b32-b10b-9e966e8d8058

https://github.com/user-attachments/assets/cc3e7f07-8b11-4774-978e-d9ff69aba707

https://github.com/user-attachments/assets/68d21a61-6fec-4464-893a-d733d67ae17b

https://github.com/user-attachments/assets/f854fc6a-df33-416d-998d-2180158effc8

https://github.com/user-attachments/assets/cc02e5e6-55f9-41ef-886d-86d8b8b68af9

https://github.com/user-attachments/assets/ebf9c0fe-0e07-4232-a29b-690e351693b7

https://github.com/user-attachments/assets/8da624f1-be24-4927-9858-717cc8a1b77f

https://github.com/user-attachments/assets/3bece84f-302c-4e9b-8203-000e037ca00f

https://github.com/user-attachments/assets/690ed102-22e1-4564-8cc8-7d43ffe5a4fc

https://github.com/user-attachments/assets/7479f8ae-60b1-407e-8bcf-fb7f8b2ec43c



For the sake of paper version of my master thesis and for pdf readers who are not capable of presenting animations correctly, the versions with static streamlines were made and are visible below

https://github.com/user-attachments/assets/d106e6dd-03c7-484e-bada-45f9bcbd5963

https://github.com/user-attachments/assets/7743c804-cce3-43b0-8c99-57a483eec6cc

https://github.com/user-attachments/assets/3a79cca5-e3b4-4ce0-98f5-011c82596a88

https://github.com/user-attachments/assets/05bbd25e-2607-4805-b024-cd2fda54dcb2

https://github.com/user-attachments/assets/03b78d72-b23e-4767-b97a-4f50eca8ce55

https://github.com/user-attachments/assets/6af7df09-b3bf-4f3c-8b99-892d3fd921aa

https://github.com/user-attachments/assets/19c4399c-52a5-4dc0-bfa7-58e40258ce2a

https://github.com/user-attachments/assets/320086f7-5cfc-440c-bcbc-a87f3e6977f3

https://github.com/user-attachments/assets/4a5dbd5a-70f1-4ce1-98f0-c03abe9f3654

https://github.com/user-attachments/assets/2f71db99-431e-41de-8007-d05108edd676

https://github.com/user-attachments/assets/d155b5f0-6dc0-452f-9417-3632c96b40b4

https://github.com/user-attachments/assets/9aeb0a57-f4ce-43eb-9caa-eb5d546ad144

https://github.com/user-attachments/assets/7442ac1d-45e4-4b73-b331-5be81349ed11



