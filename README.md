## Releases/download
Get the latest windows release here:  
>https://github.com/Watteco/TriphasoTool/releases  

Or on the right of your screen in the *Releases* section.  

# TriphasoTool
Tool for Triphaso developped with flutter.  
It allows an easy way to read data sent by the Triphaso by uart. And also to have a visual aspect of them.  
Compatible with software starting from V3.5.2.5958  

## Software Tools
* Visual Studio Code with flutter (https://code.visualstudio.com/download)  
* Driver Usb400 if using USB400 converter to get uart data (https://www.acksys.fr/produit/30-usb400/)  
* Inno Setup (https://jrsoftware.org/isdl.php)

## Sensors
* Triphas'O
* USB400 Converter or USB-RS485-WE (https://fr.rs-online.com/web/p/convertisseurs-et-adaptateurs-d-interface/6877834)

For the USB400 Converter you will need to connect respectively the 'A' and 'B' pins to the 'B' and 'A' pins of the Triphas'O. 

![Photo of the USB400 Converter](images/usb400Converter.jpg?raw=true "Photo of the USB400 Converter")

For the converter USB-RS485 you will need to connect respectively the orange and yellow wires to the 'A' and 'B' pins of the Triphas'O.  
Otherwise, you will have strange characters on the serial port com.

If the converter cable is longer than 1 meter, you will need to push the yellow button (in back position) beside the uart port.

## Software Installation
* Follow the instructions here:
>https://docs.flutter.dev/get-started/install/windows

To make flutter work best, you'll need visual studio code and android studio on your computer.

For this version of the TriphasoTool, you will need to download Dart and Flutter 3.3.0 
(you can install them with Visual Studio code by typing your extension's name, going to parameters and choosing "Install Specific Version...").

You will also need to download the Flutter SDK manually (version 3.3.5 stable) at the URL https://docs.flutter.dev/release/archive .

You shouldn't put your SDK folder in your project folder in order to avoid some errors.

### Architecture Code
*main.dart* contains the main code used to launch the application is in /lib. The main page is composed of a banner with a drawer and a body part.   
The body part change when the user click on an item from the drawer.  
Each body part code are stored in the body directory.   
Each classes are in the classes directory.  

### Executable creation

#### 1. Build the project

First you must input the following command in the *flutter project terminal*

>flutter build windows

It will build (in windows) your project at the following location, but only for you tu use.

><project>/../build/windows/runner/release/

To make it redistribuable, we'll use *Inno setup*.
The following procedure has to be done *once* for a computer, a script file is then created and allows you to build it again without redoing everything.

#### 2. Open the Inno setup software

Install Inno and open it, then select the option *“create a new script file using the script wizard”*.

![The Inno setup software welcome screen](images/innoSetup1.png?raw=true "The welcome screen")

If this window doesn't show, use *File -> New..* (or Ctrl+N)

#### 3. Fill out information about the software

Then fill out the following information:

>Application name: TriphasoTool  
>Application version: (You know it better than I)  
>Application publisher: Watteco  
>Application website: https://watteco.fr/  

![Screenshot of the setup wizard with the information above filled in](images/innoSetup2.png?raw=true "App info window")

Press next twice.

#### 4. Select the required application files

With the *Browse* button, add the exe files of the project.
It should be located in *<project>/../build/windows/runner/release/*

Then, with the *Add file(s)* button, add the exe again, along with all the .dll files.

With the *Add folder* button, add the "data" folder, and press yes if a confirmation about adding subfolders too appears.

Select the new "data" folder form the list on te left, then press edit. A new window should appear, input "data" (without the quotes) in the *"Destination folder:"* input field then press "Ok".

![Screenshot of the application files window, with the instructions above written on](images/innoSetup3.png?raw=true "Application files window")

Press next.

#### 5. Finish the setup

In the Application file association window, uncheck the checkbox, then press next.

Press next until you reach the compiler settings.

>Custom compiler output folder: A path of your choice  
>Compiler output base file name: TriphasoTool Setup  
>Custom setup icon file: Found in *<project>/../images/W-Icon.ico*  
>Setup password: Leave empty  

Then click on next, until finish.

#### 6. Create the script

Click *Yes* on any confirmation window. You'll be asked to save the script, save it *on your computer*.
After the end of this procedure, you'll be able to build the setup again just by changing the version in the script and building it again.

The executable setup shoud now be in the *custom compiler output folder* you selected. You can now freely distribute it.

### *For Watteco members:*
After each major modification of the app, don't forget to change the app version on the script and on the application in the *lib/main.dart* file.  
```
  // =========================== CHANGE VERSION HERE ===========================
  static const appVersion = 'X.X';
  // ===========================================================================
```
When incrementing the version don't forget to publish a new release with an official installer and a changelog.

To do so, produce a new installer of the new version as explained in the *Executable creation* section above.  
After creation, rename the setup "TriphasoTool v*X.X* Setup" (with the new version number).  
Then go to https://github.com/Watteco/TriphasoTool/releases and click "*Draft a new release*".  
Create a new tag named "vX.X" with the new version number and set the title as "Triphas'O Tool *X.X*" (again with the new version number).  
Write what changed since the previous official release, for instance:  
```
### Triphas'O Tool v1.1
#### Changes from the initial 1.0 release:

 - Added a config file to customize serial transmission speed
 - Increased the default transmission speed to 460800
 ...
```
Then add your created installer before clicking on "*Publish release*".

## Triphaso Cluster
The clusters "Energy And Power Multi Metering" and "Voltage and Current Multi Metering" are the ones used to receive data in signed values.   
So, it is the ones you will need to configure in order to see changes in the app.     

### Triphaso Configuration
* Serial baudRate : 460800 by default, editable in *TriphasoTool/data/flutter_assets/assets/config.json*
* Serial bits : 8
* Serial parity : 0 (n)
* Serial stopBits : 1
* Serial rts : RTS on TX 
* Serial dtr, xonXoff : 0

### Serial Protocol explanation
4 frames sending each second  
The first frame is for the 'Phase 1' values, the 2nd for 'Phase 2', the 3rd for 'Phase 3' and the 4th for 'Phase A+B+C'  
The data sent in order are : Phase - Mode - Voltage - Current - Angle - Active Power - Reactive Power - Average Active Power - Average Reactive Power - Active Energy - Reactive Energy - Average Timing   

The sensor can be in 3 differents mode : S (star), D (delta) and M (Monophase)
