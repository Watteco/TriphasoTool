# TriphasoTool
Tool for Triphaso developped with flutter.  
It allows an easy way to read data sent by the Triphaso by uart. And also to have a visual aspect of them.  
Compatible with software starting from V3.5.2.5958  

## Software Tools
* Visual Studio Code with flutter (https://code.visualstudio.com/download)  
* Driver Usb400 if using USB400 converter to get uart data (https://www.acksys.fr/produit/30-usb400/)  

## Sensors
* Triphas'O
* USB400 Converter or USB-RS485-WE (https://fr.rs-online.com/web/p/convertisseurs-et-adaptateurs-d-interface/6877834)

For the USB400 Converter you will need to connect respectively the 'A' and 'B' pins to the 'B' and 'A' pins of the Triphas'O. 
![Alt text](images/usb400converter.jpg?raw=true "Title")

For the converter USB-RS485 you will need to connect respectively the orange and yellow wires the 'A' and 'B' pins of the Triphas'O.0  
Otherwise, you will have strange caracteres on the serial port com.

## Software Installation
>https://docs.flutter.dev/get-started/install/windows

### Architecture Code
*main.dart* contains the main code used to launch the application. The main page is composed of a banner with a drawer and a body part.   
The body part change when the user click on an item from the drawer.  
Each body part code are stored in the body directory.   
Each classes are in the classes directory.  

## Triphaso Cluster
The clusters "Energy And Power Multi Metering" and "Voltage and Current Multi Metering" are the ones used to receive data in signed values.   
So, it is the ones you will need to configure in order to see changes in the app.     

### Triphaso Configuration
* Serial baudRate : 19200
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
