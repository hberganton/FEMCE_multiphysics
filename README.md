# FEMCE multiphysics

A 3D Finite Element multi-physics simulation software specialized in magnetic refrigerants. FEMCE multiphysics can simulate

- the magnetostatic interaction between a non-linear magnetic refrigerant and a source magnetic field
- a viscous fluid heat exchanger (velocity field, pressure) passing through the refrigerant
- the dynamic heat transfer between the fluid and the refrigerant

With FEMCE multiphysics, users have a full simulation suite for optimizing magnetocaloric regenerators.

## Table of Contents
- [Magnetostatics](#magnetostatic-model-description)
- [3D Models](#geometries-available)
- [Setup](#simulation-setup)
- [Short tutorial](#using-the-interface)
- [Example plots](#example-plots)




## Magnetostatic model description

FEMCE multiphysics employs the state-of-the-art Newton-Raphson method to simulate non-linear magnetic refrigerants, under two modes of operation:
- Applying and fully removing the magnetic field source
- Rotating the refrigerant inside a magnetic field (MCE induced by shape anisotropy)

## Geometries available

FEMCE multiphysics requires a 3D tetrahedral mesh with 2nd order Lagrange elements (quadratic elements). FEMCE multiphysics provides some default examples such as INSERT EXAMPLES


## Simulation setup

A ``.mat`` file containing a MATLAB FEGeometry object called ``model`` must be given as an input. The ``model`` variable must contain a quadratic order mesh aready generated. The model geometry should contain:

- an outer tube;
- an inner tube (optional);
- a magnetic refrigerant.

The provided script ``build_custom_mesh.m`` (which can be executed in MATLAB) creates an example model that is ready for use and saves it in ``Mesh/custom_model.mat``. The user is free to modify the parameters of the given geometry at will.

The files ``Mesh/inscribed_plates.mat``,``Mesh/sphere.mat``, and ``Mesh/plate.mat`` contain pre-prepared example models.

The file ``input_parameters.txt`` contains the simulation setup for APPNAME, including:

- magnet bore length ``L_magnet``;
- maximum fluid velocity ``u_max``;
- number of simulated temperatures``nT``.
- etc.

The meaning of each input parameter is indicated by comments in the script. In the Geometry data section, we recommend only ``L_magnet``,``ScaleFactor`` and ``x_refrigerant`` to be touched, unless the user desires to switch to a different container setup (not the double cylinder setup that is set by default). 

Lastly, a material data folder needs to be provided. This is identical to the one in FEMCE, and the folder ``Materials/Gd_FEMCE`` containing sample data for Gd is included.

## Using the interface

The app itself contains two tabs, the **Simulation panel** and the **Results panel**. The simulation panel includes an empty model view plot and several buttons, most of which have lights beside them.

### Simulation panel

When booting up the FEMCE.multiphysics, the user should be greeted with an interface that looks like this:

<img width="604" height="674" alt="initial_screen" src="https://github.com/user-attachments/assets/4bd282e0-9d84-41ef-b8af-da459f353269" />

To start, the user should press the **Load Model** button and select the desired ``.mat`` file. The user should now see the model in te model view plot. The image below shows the screen after loading ``inscribed_plates.mat``

<img width="616" height="496" alt="after_loading" src="https://github.com/user-attachments/assets/44d0cebd-bc01-4da1-b5d8-c0ea9b104fea" />

The user should also press the **Load Material** button and select the material FOLDER. If the user doesn't load a model or a material, the app will default to ``Mesh/sphere.mat`` and ``Materials/Gd_FEMCE/``.

Once the material and model are loaded, the user should press the **Prepare** button. This will ask for the input parameters file, and then make all of the necessary preparations for the simulations. If the user has not provided a model and/or folder, they will be prompted to do it now. Once this is done, the light beside the Prepare button should turn green, and the lights beside the Run Fluid and Run MCE buttons should turn blue. This means these buttons are ready to be pressed. 

<img width="617" height="467" alt="after_preparing" src="https://github.com/user-attachments/assets/fae7a253-a9de-4eed-92db-ab45343a4489" />

Now is the time to run simulations.

The **Run Fluid** button will simulate the fluid velocity with the given ``u_max`` and ``mu`` inputs. Once the simulation is done, the light will turn green. This simulation should take no longer than a few minutes on reasonably modern hardware with the pre-prepared meshes.

The **Run MCE** button will run a magnetostatics simulations for all temperatures and stages defined in the input file, calculating the adiabatic $\Delta T$ along the way. Once this is done, the light will turn green. Each magnetostatic simulation takes only a few seconds, however, the number of simuations is ``nT*Nx*nStages``. In the default configurations file, there are 6 temperatures, 10 x values and 6 stages, for a total of 360 simulations, so be prepared to wait a few minutes.

After both the fluid and the MCE simulations were done, the Run Heat Transfer light should have turned blue, like shown below:

<img width="617" height="496" alt="before_heat" src="https://github.com/user-attachments/assets/881878b8-783e-4030-9add-3b39d1cbfc7f" />

If both the fluid and MCE simulations have been done and the MCE simulations were adiabatic, the light beside the **Run Heat transfer** button will have turned blue. The user may now press it to simulate the heat transfer with the given ``total_time`` and ``nSteps``, as well as the calculated fluid velocity and adiabatic $\Delta T$. This step takes by far the longest, as there are ``nT*nStages`` simulations, and each of them takes a similar amount of time to the fluid simulation or even longer. Be prepared to wait for many minutes or even a few hours for this result, even in the pre-prepared meshes.

After the heat transfer simulations are done, all of the lights should be green, as shown below, and the user should proceed to the results panel.

<img width="617" height="496" alt="all_done" src="https://github.com/user-attachments/assets/7f06e879-95c6-46ef-a728-747aa55d5952" />


### Results panel

After running the simulation, users may turn to this page to view or export the results. A screenshot of the page is shown below:

<img width="617" height="497" alt="results_page" src="https://github.com/user-attachments/assets/709fa245-da56-476c-bf4f-0f9e487faf1b" />


The **Export results** button will save a matlab structure() called ``results`` into the file with the given input name. If no file name is given, the app will default to ``results.mat``. The saved variables are:

- ``nStages``: number of stages in the Stagedef input matrix;
- ``nT``: number of temperatures simulated;
- ``Nx``: number of x or theta values simulated per temperature and stage;
- ``W``: the magnetic work required to generate each configuration. It is an ``(Nx,nT,nStages)`` sized matrix;
- ``Fgen``: the generalized force (force or torque) at each configuration. It is an ``(Nx,nT,nStages)`` sized matrix;
- ``Q``: the heat absorbed by the refrigerant at the end of each stage. It is an ``(nT,nStages)`` sized matrix;
- ``DeltaS``: the isothermal entropy at the end of each stage. The value is zero if the simulations were adiabatic. It is an ``(nT,nStages)`` sized matrix;
- ``HLtime``: the half-life time of decay of the $\Delta T$ in the heat transfer. It is an ``(nT,nStages)`` sized matrix;
- ``HLtime``: the time it takes for $\Delta T$ to decay to 0.5 K the heat transfer. It is an ``(nT,nStages)`` sized matrix;
- ``T``: the final temperature of each element at each stage. It is a ``(nElements,nT,nStages)`` sized matrix. This is the temperature at the end of the MCE simulation, NOT the Heat transfer simulation.
- ``mu0H`` is the value of $\mu_0 H$ at each element at the end of each stage. It is a ``(nElements,nT,nStages)`` sized matrix. 

The big **PLOT** button will plot whatever quantity is in the **variable to plot:** box. The available options are:

- **Fluid speed** (requires fluid simulation);
- **Fluid pressure** (requires fluid simulation);
- **Work** (requires MCE simulation);
- **Peak force** (requires MCE simulation);
- **Heat** (requires MCE simulation)
- **Delta T** (requires MCE simulation)
- **Heat-per-work** (requires MCE simulation)
- **Half-life time** (requires Heat Transfer simulation)
- **Time to 0.5 K** (requires Heat Transfer simulation)

## Example plots

The user is encouraged to explore the plotting options. Below are a few examples:

(1) fluid speed around a sphere:

<img width="560" height="420" alt="fluid_speed" src="https://github.com/user-attachments/assets/055c0f93-ef44-4291-aa73-32b8f06b362c" />

(2) adiabatic $\Delta T$ of a sphere at 1.2 T, compared between translation and rotation (the rotating $\Delta T is zero, since the sphere is rotationally symmetric).

<img width="560" height="420" alt="deltaT" src="https://github.com/user-attachments/assets/ad3be9b2-ec8f-4e83-a303-5760354a42ac" />

(3) adiabatic $\Delta T$ of a thin plate at 1.2 T, compared between translation and rotation.

<img width="560" height="420" alt="deltaT_placa" src="https://github.com/user-attachments/assets/52bae005-3f62-45ff-a589-8333732abc6f" />

(4) Time it takes for the temperature of the same thin plate to increase by 0.5 K after an adiabatic demagnetization.

<img width="560" height="420" alt="timetohalfK" src="https://github.com/user-attachments/assets/c71a1dd4-e8e2-4b99-9a21-8938368492b4" />





