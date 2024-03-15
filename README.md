# Flutter Markup Language

[![GitHub Release](https://img.shields.io/github/v/release/AppDaddy-Software-Solutions-Inc/Flutter-Markup-Language.svg?label=release%20version&style=plastic&logo=data:image/png;base64,iVBORw0KGgoAAAANSUhEUgAAAA4AAAAOCAYAAAAfSC3RAAACQElEQVQokZ2STUhUYRSG3+/77p07M/5MqVM0piXOJkpIMiENwomsdgnSIvtZhIHYPshdVLZrEUSCC2nnQtsULRKTyjJuf4JM9jOkWKN1jZzRmTtz7/2+E6NCP0vP4iwO533fA8/BRou1jjvg4ABbc1BKaSAaYBC7SspFac6HU3NTlhkfHoE7Ow90tsNXWw3t/0DO2Dml0KEZgOdhOTn1NTFjxiHzDqD/Wf9HSETnGVi/pgmIIBuduPvw7MKzyX0oK00hGJAQ2mvQesBqXzvzAgj9RFSwm8g76vDPzwuLsN2bCPpfQvBXSC/dAqlVFV8P6yKiPhRmgj/3pDzAiaGpsy0fbWtuQjoziQ8zwO6tF7EjfBvLEhpj7Cop6ikYBQz22FEUg8eOK0lVFTs31ZTtifXlHLn3l+0+zbQdPQhPdMHOlWuk4GcEFBtsYsZBrIzoUrHADVsqLFnSTH1nPQ1njjQKDVUjCUIqa8NXpI+zltE8QsWie17y++YPp6NcsGsttT5PD2AwaeG07soTXOFeAAQPwBMb7TliQ6x1LA9hcJgpdWgxT2MIGwi//5SsTKcqt8UaIkV+mJlFlZNKrYT8/MqLFRqadwiaxhlSOQXheKYeDl52J83r1sCDiOUrGfw2Pde9vbEuGqmPugbnynGU8mgNglbAIjgDN/Qsl24vHr0hlG7uRUXopBVP7LfiX+oTZo1dd6wZldEtwIr8i+MqSwZyPEAP3oHfGAbRW4RDWQR91el301j4OAvd2PBrrxeA3wx//v4Gwt9jAAAAAElFTkSuQmCC&logoWidth=14)](https://github.com/AppDaddy-Software-Solutions-Inc/Flutter-Markup-Language/releases)
[![GitHub Stars](https://img.shields.io/github/stars/AppDaddy-Software-Solutions-Inc/Flutter-Markup-Language.svg?label=github%20stars&style=plastic&logo=data:image/png;base64,iVBORw0KGgoAAAANSUhEUgAAAA4AAAAOCAYAAAAfSC3RAAACQElEQVQokZ2STUhUYRSG3+/77p07M/5MqVM0piXOJkpIMiENwomsdgnSIvtZhIHYPshdVLZrEUSCC2nnQtsULRKTyjJuf4JM9jOkWKN1jZzRmTtz7/2+E6NCP0vP4iwO533fA8/BRou1jjvg4ABbc1BKaSAaYBC7SspFac6HU3NTlhkfHoE7Ow90tsNXWw3t/0DO2Dml0KEZgOdhOTn1NTFjxiHzDqD/Wf9HSETnGVi/pgmIIBuduPvw7MKzyX0oK00hGJAQ2mvQesBqXzvzAgj9RFSwm8g76vDPzwuLsN2bCPpfQvBXSC/dAqlVFV8P6yKiPhRmgj/3pDzAiaGpsy0fbWtuQjoziQ8zwO6tF7EjfBvLEhpj7Cop6ikYBQz22FEUg8eOK0lVFTs31ZTtifXlHLn3l+0+zbQdPQhPdMHOlWuk4GcEFBtsYsZBrIzoUrHADVsqLFnSTH1nPQ1njjQKDVUjCUIqa8NXpI+zltE8QsWie17y++YPp6NcsGsttT5PD2AwaeG07soTXOFeAAQPwBMb7TliQ6x1LA9hcJgpdWgxT2MIGwi//5SsTKcqt8UaIkV+mJlFlZNKrYT8/MqLFRqadwiaxhlSOQXheKYeDl52J83r1sCDiOUrGfw2Pde9vbEuGqmPugbnynGU8mgNglbAIjgDN/Qsl24vHr0hlG7uRUXopBVP7LfiX+oTZo1dd6wZldEtwIr8i+MqSwZyPEAP3oHfGAbRW4RDWQR91el301j4OAvd2PBrrxeA3wx//v4Gwt9jAAAAAElFTkSuQmCC&logoWidth=14)](https://github.com/AppDaddy-Software-Solutions-Inc/Flutter-Markup-Language)
[![GitHub Contributors](https://img.shields.io/github/contributors/AppDaddy-Software-Solutions-Inc/Flutter-Markup-Language.svg?label=contributers&style=plastic&logo=data:image/png;base64,iVBORw0KGgoAAAANSUhEUgAAAA4AAAAOCAYAAAAfSC3RAAACQElEQVQokZ2STUhUYRSG3+/77p07M/5MqVM0piXOJkpIMiENwomsdgnSIvtZhIHYPshdVLZrEUSCC2nnQtsULRKTyjJuf4JM9jOkWKN1jZzRmTtz7/2+E6NCP0vP4iwO533fA8/BRou1jjvg4ABbc1BKaSAaYBC7SspFac6HU3NTlhkfHoE7Ow90tsNXWw3t/0DO2Dml0KEZgOdhOTn1NTFjxiHzDqD/Wf9HSETnGVi/pgmIIBuduPvw7MKzyX0oK00hGJAQ2mvQesBqXzvzAgj9RFSwm8g76vDPzwuLsN2bCPpfQvBXSC/dAqlVFV8P6yKiPhRmgj/3pDzAiaGpsy0fbWtuQjoziQ8zwO6tF7EjfBvLEhpj7Cop6ikYBQz22FEUg8eOK0lVFTs31ZTtifXlHLn3l+0+zbQdPQhPdMHOlWuk4GcEFBtsYsZBrIzoUrHADVsqLFnSTH1nPQ1njjQKDVUjCUIqa8NXpI+zltE8QsWie17y++YPp6NcsGsttT5PD2AwaeG07soTXOFeAAQPwBMb7TliQ6x1LA9hcJgpdWgxT2MIGwi//5SsTKcqt8UaIkV+mJlFlZNKrYT8/MqLFRqadwiaxhlSOQXheKYeDl52J83r1sCDiOUrGfw2Pde9vbEuGqmPugbnynGU8mgNglbAIjgDN/Qsl24vHr0hlG7uRUXopBVP7LfiX+oTZo1dd6wZldEtwIr8i+MqSwZyPEAP3oHfGAbRW4RDWQR91el301j4OAvd2PBrrxeA3wx//v4Gwt9jAAAAAElFTkSuQmCC&logoWidth=14)](https://github.com/AppDaddy-Software-Solutions-Inc/Flutter-Markup-Language/graphs/contributors)
[![Discord](https://img.shields.io/discord/881948709963849749.svg?label=discord&style=plastic&logo=data:image/png;base64,iVBORw0KGgoAAAANSUhEUgAAAA4AAAAOCAYAAAAfSC3RAAACQElEQVQokZ2STUhUYRSG3+/77p07M/5MqVM0piXOJkpIMiENwomsdgnSIvtZhIHYPshdVLZrEUSCC2nnQtsULRKTyjJuf4JM9jOkWKN1jZzRmTtz7/2+E6NCP0vP4iwO533fA8/BRou1jjvg4ABbc1BKaSAaYBC7SspFac6HU3NTlhkfHoE7Ow90tsNXWw3t/0DO2Dml0KEZgOdhOTn1NTFjxiHzDqD/Wf9HSETnGVi/pgmIIBuduPvw7MKzyX0oK00hGJAQ2mvQesBqXzvzAgj9RFSwm8g76vDPzwuLsN2bCPpfQvBXSC/dAqlVFV8P6yKiPhRmgj/3pDzAiaGpsy0fbWtuQjoziQ8zwO6tF7EjfBvLEhpj7Cop6ikYBQz22FEUg8eOK0lVFTs31ZTtifXlHLn3l+0+zbQdPQhPdMHOlWuk4GcEFBtsYsZBrIzoUrHADVsqLFnSTH1nPQ1njjQKDVUjCUIqa8NXpI+zltE8QsWie17y++YPp6NcsGsttT5PD2AwaeG07soTXOFeAAQPwBMb7TliQ6x1LA9hcJgpdWgxT2MIGwi//5SsTKcqt8UaIkV+mJlFlZNKrYT8/MqLFRqadwiaxhlSOQXheKYeDl52J83r1sCDiOUrGfw2Pde9vbEuGqmPugbnynGU8mgNglbAIjgDN/Qsl24vHr0hlG7uRUXopBVP7LfiX+oTZo1dd6wZldEtwIr8i+MqSwZyPEAP3oHfGAbRW4RDWQR91el301j4OAvd2PBrrxeA3wx//v4Gwt9jAAAAAElFTkSuQmCC&logoWidth=14)](https://discord.gg/hbFbajpuUG)
<!-- [![GitHub Downloads](https://img.shields.io/github/downloads/AppDaddy-Software-Solutions-Inc/Flutter-Markup-Language/total.svg?label=github%20downloads&style=plastic&logo=data:image/png;base64,iVBORw0KGgoAAAANSUhEUgAAAA4AAAAOCAYAAAAfSC3RAAACQElEQVQokZ2STUhUYRSG3+/77p07M/5MqVM0piXOJkpIMiENwomsdgnSIvtZhIHYPshdVLZrEUSCC2nnQtsULRKTyjJuf4JM9jOkWKN1jZzRmTtz7/2+E6NCP0vP4iwO533fA8/BRou1jjvg4ABbc1BKaSAaYBC7SspFac6HU3NTlhkfHoE7Ow90tsNXWw3t/0DO2Dml0KEZgOdhOTn1NTFjxiHzDqD/Wf9HSETnGVi/pgmIIBuduPvw7MKzyX0oK00hGJAQ2mvQesBqXzvzAgj9RFSwm8g76vDPzwuLsN2bCPpfQvBXSC/dAqlVFV8P6yKiPhRmgj/3pDzAiaGpsy0fbWtuQjoziQ8zwO6tF7EjfBvLEhpj7Cop6ikYBQz22FEUg8eOK0lVFTs31ZTtifXlHLn3l+0+zbQdPQhPdMHOlWuk4GcEFBtsYsZBrIzoUrHADVsqLFnSTH1nPQ1njjQKDVUjCUIqa8NXpI+zltE8QsWie17y++YPp6NcsGsttT5PD2AwaeG07soTXOFeAAQPwBMb7TliQ6x1LA9hcJgpdWgxT2MIGwi//5SsTKcqt8UaIkV+mJlFlZNKrYT8/MqLFRqadwiaxhlSOQXheKYeDl52J83r1sCDiOUrGfw2Pde9vbEuGqmPugbnynGU8mgNglbAIjgDN/Qsl24vHr0hlG7uRUXopBVP7LfiX+oTZo1dd6wZldEtwIr8i+MqSwZyPEAP3oHfGAbRW4RDWQR91el301j4OAvd2PBrrxeA3wx//v4Gwt9jAAAAAElFTkSuQmCC&logoWidth=14)](https://github.com/AppDaddy-Software-Solutions-Inc/Flutter-Markup-Language) -->

## Disclaimer
This is a commercial package. To use this package, you need comply with the FML fair source [**License**](https://fml.dev/license.pdf)

## Why FML?

##### 1. **Faster Development &rarr; Prototype to Application**
As software developers we know the importance of prototyping but the gap between a non-functional prototype, a functional prototype and an actual application is wide. Solutions either sacrificed capability or time, FML is specifically designed to be able to create a non-functional prototype skeleton which can be fleshed into a functional prototype by additional syntax/parameters. The simplicity of the language requires only modifications/tweaks to complete an application. One huge advantage of this is that pieces of the application can be at different prototyping stages depending on the development while still working as a whole application, this optimization offers a lot of flexibility for design, development and testing.

##### 2. **Lower Cost &rarr; Single Codebase**
Write once, run everywhere, an age old ideal but we are confident in our no compromises approach. Quicker development, lower maintenance cost. FML has built in all the platform implementations and UI idiosyncrasies for the developer. This promotes a more uniform application relieving the developer from being an expert on each platform and removing code duplication. Furthermore everything can be modified from looks to functionality if you wish to override the default behavior.

##### 3. **Shorter Learning Curve &rarr; Simplicity without Sacrificing Power or Performance**
The syntactic sugar FML provides for designing user interfaces with the functional power of data binding, logic interpretation and pre-defined events gives developers the best of both worlds. Run into a roadblock with something FML can't do? Let us know and we will make it possible. We don't believe FML should limit any application functionality, our goal is to make it faster and easier to achieve the same functionality as writing in a programming language.

## Resources

##### 1. **FML Online**
To learn more about what FML can do for you or your company and get started building applications, visit [**fml.dev**](https://fml.dev/).

##### 2. **Documentation**
For a full language overview of FML, check out our [**wiki**](https://github.com/AppDaddy-Software-Solutions-Inc/Flutter-Markup-Language/wiki/Home).

##### 3. **Quick Start Guide**
If you want to dive right in, have a look at our [**quick start guide**](https://github.com/AppDaddy-Software-Solutions-Inc/Flutter-Markup-Language/wiki/Quick-Start-Guide).

##### 4. **Technical Briefs**
Read published [**articles**](https://medium.com/@TheOlajos)

##### 5. **Videos**
Watch our [**videos**](https://www.youtube.com/channel/UC96zHGCBQT_yklB1cKgR0qQ?sub_confirmation=1)

##### 6. **FML Pad (New!)**
Try out [**FmlPad**](https://pad.fml.dev)

## Installation
##### 1. **Create a new project with support for all platforms**

from the commmand line, run:

```
$flutter create --org com.<your_domain_name> --platforms=android,ios,linux,macos,windows,web <your_app_name>
```

##### 2. **Open the project in your SDK (ex. Android Studio)**

##### 3. **Download sample main.dart**

Download and extract the sample [**main.dart**](https://fml.dev/downloads/fml-wrapper-files.zip) file.

You can replace main.dart in your projects /lib folder with the main.dart from the .zip file.

##### 4. **Download supporting web files**

Download the [**web support files**](https://fml.dev/downloads/fml-wrapper-web-files.zip) and place them in your projects root level web folder. When asked to replace, choose "yes".

##### 5. **Download supporting assets**

Create a new folder at the project root called "assets".

Download the [**supporting assets**](https://fml.dev/downloads/fml-wrapper-assets.zip) and place them in the newly created assets folder. If asked to replace, choose "yes".

##### 6. **Modify your pubspec.yaml file**

Download and extract the sample [**pubspec.yaml**](https://fml.dev/downloads/fml-wrapper-files.zip) file.

Modify your projects **pubspec.yaml** file.

a) Add the fml engine package: 

```
fml: ^3.0.0
```

b) Add the assets reference

```
assets:
- assets/
- assets/images/
- assets/applications/

- assets/applications/example/
- assets/applications/example/images/
- assets/applications/example/templates/

- assets/applications/fmlpad/
- assets/applications/fmlpad/images/
- assets/applications/fmlpad/templates/
```

##### 7. **Try running your new app in the web browser**

Ensure **domain: example1** is set in the FmlEngine() constructor of your new main.dart file.
Choose the web browser from the build options and compile and run. If all goes well, you should see the [**test.appdaddy.co**](https://fml.dev/downloads/main.zip) web site running on your local host. 
In this scneario, FMNL templates rae being server from that web site.  

##### 8. **Try running your new app on the windows desktop (Single App Mode)**

On your fml engine constructor in main.dart, change:

```
FmlEngine(
...
domain: example2,
multiApp: false,
...);
```

Choose "windows" from the build options and compile and run. If all does well, a desktop window will launch and the FML example application displayed. The templates for this application are 
located in your local /assets/appications/example folder. The config.xml file in this folder controls various aspects of the site and can be modified accordingly.

##### 9. **Try running your new app on the windows desktop (Multi App Mode)**

On your fml engine constructor in main.dart, change:

```
FmlEngine(
...
multiApp: true,
...);
```

Choose "windows" from the build options and compile and run. If all does well, a desktop window will launch and the store displayed with no application (empty container). 

To add the same example we launched above in single app mode, click the "Add App" button, enter the url **file://example** and name **The Example App** at the appropriate prompts. 

You can also add the **FML PAD** app by clicking the "Add App" button a second time and entering url **file://fmlpad** and name **Fml Pad** at the appropriate prompts.

Clicking on either of these buttons will lauch the application. You can use the mopsue to swipe back or add a back() btton to the template yourself.

##### 10. **Android Mobile Support**

Your can download [**android support files**](https://fml.dev/downloads/fml-wrapper-android-files.zip)

(a) Modify AndroidManifest.xml located in the **/android/app/src/main** folder of your application.

Add Permissions:
```
<uses-permission android:name="android.permission.INTERNET" android:required="true" />
<uses-permission android:name="android.permission.ACCESS_NETWORK_STATE" />
<uses-permission android:name="android.permission.NFC" />
<uses-permission android:name="android.permission.ACCESS_FINE_LOCATION" />
<uses-permission android:name="android.permission.ACCESS_COURSE_LOCATION" />
<uses-permission android:name="android.permission.RECORD_AUDIO" android:required="true" />
<uses-permission android:name="android.permission.MODIFY_AUDIO_SETTINGS" android:required="true" />
<uses-permission android:name="android.permission.CAMERA" />
<uses-permission android:name="android.permission.FLASHLIGHT" />
<uses-permission android:name="android.permission.BLUETOOTH" />
<uses-permission android:name="android.permission.BLUETOOTH_ADMIN" />
<uses-permission android:name="android.permission.BLUETOOTH_CONNECT" />
```

Add Features:

```
<uses-feature android:name="android.hardware.nfc" android:required="true" />
<uses-feature android:name="android.hardware.camera" />
```

Add Query:

```
<queries>
    <intent>
    <action android:name="android.speech.RecognitionService" />
    </intent>
</queries>
```

Add Intent Filters:

```
<intent-filter>
    <action android:name="android.intent.action.MAIN"/>
    <category android:name="android.intent.category.LAUNCHER"/>
</intent-filter>

<intent-filter>
    <action android:name="android.nfc.action.NDEF_DISCOVERED" />
    <category android:name="android.intent.category.DEFAULT" />
    <data android:scheme="*" />
</intent-filter>

<meta-data android:name="flutter_deeplinking_enabled" android:value="true" />
<intent-filter android:autoVerify="true">
    <action android:name="android.intent.action.VIEW" />
    <category android:name="android.intent.category.DEFAULT" />
    <category android:name="android.intent.category.BROWSABLE" />
    <data android:scheme="fml" android:host="open" />
</intent-filter>
```

b) Modify your settings.gradle file (found in your projects /android root folder) plugin section to the following versions of android and kotlin 

```
plugins {
id "dev.flutter.flutter-plugin-loader" version "1.0.0"
id "com.android.application" version "7.3.0" apply false
id "org.jetbrains.kotlin.android" version "1.9.23" apply false
}
```

b) For ZEBRA device support, including barcode scanning and RFID, you will need to modify the projects MainActivity.kt file and add the Zebra.kt file.

Extract MainActivity.kt and Zebra.kt from the [**android support files**](https://fml.dev/downloads/fml-wrapper-android-files.zip) package. Place these 2
files in your projects android/app/src/main/kotin/../.. subfolder where the MainActivity.kt file is currently located.  When asked to replace, choose "yes".