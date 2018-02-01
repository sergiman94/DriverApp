# Driver App

This project is based on a platform about an "uber" clone, this is the rider repository it means this is where the user  
request the "uber", this project is developed in "swift3" programming language and using the Xcode 9 program, This app 
doesn't work without the rider reception, also we are working with a google database system, if you want to create your
own database go to https://firebase.google.com/ the page tells you step by step how to create your own database system
with swiftt 3 and Xcode9.

## Getting Started

This project is for Xcode 9, you should have installed Cocoapods, if you haven't installed Cocoapods go to the web page 
https://cocoapods.org/ there is a brief explanation about how to install them.

### Prerequisites

you will need this pods:

    ```
    pod 'Firebase'
    pod 'Firebase/Auth'
    pod 'Firebase/Storage'
    pod 'Firebase/Database'
    pod 'Firebase/Core'
    ```
    
The app is using the Firebase database system in order to save the users and all the data, also the app is using the 
user's/driver's location in order to determine from where is the request, so on the .plist file from the Xcode project you 
should add a row with the next keys asking for the user to allow the app to get the location,the string value is on your 
own:  

    ```
    Privacy - Location Usage Description 
    Privacy - Location When In Use Usage Description
    ```

### Installing

Install Xcode 9 going to your AppStore, then do the prerequisites installing cocoapods, pods and the .plist info, check your 
firebase database system.

At the Xcode program run the project using the simulator for iPhone 8 Plus or your plugin your iPhone choosing it on the 
simulator devices section , please use a custom location in order to see how the project works on diferent locations.

## Deployment

This project is not ready for deployment on the App Store yet.

## Contributing

Please contact sergiman94@gmail.com if you want to contribute for the project.

## Versioning

We use https://github.com/ for versioning. If you have questions about the versions available, contact sergiman94@gmail.com

## Authors

* **Sergio Manrique** - *Initial work* - [sergiman94](https://github.com/sergiman94)

See also the list of [contributors](https://github.com/your/project/contributors) who participated in this project.

## License

This project is licensed under the domain of Sergio Manrique Copyright © 2018 smm. All rights reserved.

## Acknowledgments

* This code has been written using references on youtube and other public programs with learning purposes

* What we did here on the Comment branch is to xplain the areas of the code where the complexity is remarkable, also we try 
  to explain the MVC system with the comments


