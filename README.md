# grow box
This will be the code for my diploma thesis. I'm building my own grow box with my friends. At the end of this documentation you can find all the links that helped me. You can find this documentation in the pdf file which will be added.  

# description
For this project I will use a Raspberry Pi 3. The programming language is Elixir. For more informations about Elixir, you can visit the homepage. https://elixir-lang.org/.

In our grow box are a few sensors to get temperature, water levels and quality. The inputs can be seen on a website, which is also running on the Pi. A camera will take photos and make a time-lapse video. In total we will have five pumps. Four of them will be in small tanks with water, nutrient solution and a liquid to bring down the pH value of the water in the larger tank. In the larger tank all liquids are mixed together and the fourth pump will water the plants with it.

# hat
To read all these sensors and control the pumps I will design my own Raspberry Pi Header. I'll design it with the software EAGLE from autodesk. On the board will be three current sources, an ADC, a circuit to control a relays and several clamps.

# measuring the temperature
To control the leds, we have to know their temperature. For this i will use three PT100. A PT100 is a temperature-dependent resistor and with the formula you can calculate every value at a temperature. In electrical measuring technology only voltage can be measured. 

So how do we get a voltage from our PT100?
With a constant current source through the PT100. But how many amps do we need? The base for this project is a Raspberry Pi 3 and he runs with 5V but his GPIOs can only drive 3.3V and he doesn't have any ADCs, so we need one between the PT100 and Raspberry Pi. 

The ADC i chose is the MCP3008. He usually runs on 5V but we don't want to hurt the Raspberry Pi, so the ADC will be powered with 3.3V. The MCP3008 has 8 analog inputs and 10 bit resolution. 

The leds usually have a operation temperature of 85°C and a total maximum temperature of 105°C. I want to fully use the 10 bit and 3.3V, so i set the limit to 120°C.
At 120°C the PT100 has a resistance value of 146.07 Ω. 

3.3V / 146.07 = 22.438mA

This is the constant current i need. Now i just need to design and customize a constant current source. It took me some time but i finally found a simple and temperature resistant source. The current source with LM317 is simple to calculate and it is cheap. From the link below i calculated the resistor to get the needed constant current. 
(Iout = 1.25 / R) => R = 1.25 / Iout = 55.709 Ω. 

In order not to falsify the measurement, an impedance converter is placed between the ADC and PT100. 
Temperatur measurement is ready to program. 

# large pump
A large pump will keep the plants wet with nutritious water, but the Raspberry Pi can't drive the pump so i need a small circuit with a relay, a transistor and a free-wheeling diode. The relay that is used is the 40.52. When you start the grow box, you have to enter two intervals on the website. First interval is the time how long you want to water the plants and the second one is the time between watering. 

# small pumps
In the grow box will be four small tanks with pumps in it. In the first tank will be normal water to fill up the large tank. One small tanks will be filled with a pH-value rising liquid and the other one will be filled with a pH-value sinking liquid. The acidity will be measured by a special pH-sensor. In the fourth tank will be the nutritious solution for the plants. All tanks are equipped with swim-switches. A notification will be shown on the website if one switch report not enough liquid. Every pump has its own logic. But every pump will only be active, when the large pump is off. 
All small pumps are running on 12V. To control them a LM293D will be used. Its a simple motor driver. At the end of the documentation you can find a link to the L293D.

# swim switches
In total there will be six switches to check fluid level. 

# website
The website is running on the raspberry pi and it will show some data in graphs like the temperature, pH-value, nutrient solution. The user can switch manually switch on or off the large pump and leds. But after 10min the pump and leds will return to the automatic mode. On the website the user can enter the intervals for the pump and the brightness for the plants. A camera will take every 30mins a photo and at the end of the growing process the photos will be edited together to a time-lapse-video. 

# TDS sensor
In the large tank will be a TDS sensor to check the quality of the water. The output is a analog voltage which will be digitalized by a MCP3008. The value of the threshold is also an input from the user on the website. When the water quality is sinking, the small pump in the small tank with nutrient solution in it will be activated for 1s. 

# pH value sensor
The pH value sensor will also be in the large tank. It will also deliver an anlog voltage which will also be digitalized. The pH value must not fall under 5,5 and must not rise above 6,5. To stabilize the value, two small pumps will pump pH rising and sinking fluid into the large tank for 1s. 

# water tank
In one of the four small tanks will only be water. The pump will only be activated if to less water is in the large tank. The time is calculated by using the pump rate. 

# LM293D
To control all the small pumps, this chip will be used. Below you can find the link for the data sheet. It can be controlled by 5V but can drive motors with higher voltage. The raspberry pi only has to turn gpios on and off.

# MCP3008
The raspberry pi cant work with analog signals. But it has two SPI buses which can be used for ADCs like the MCP3008. Below you can find again the library and tutorial how you can digitalize analog signal by using MCP300x and Elixir.

# Code
Now i will explain how my code works. Elixir is a functional programming language. The Website is a process which is running on its own and the grow box is also a process. Between these two is a connection for communication. For this communication the library pub-sub is used. The grow box is responsible for the whole logic and it will tick and send the complete state to the website which will show it in graphs. But between the grow box and the website all the stuff to control and get data are hanging in the line. They are also working on themself as processes. Some libraries are needed to control everything like for pwm and gpios.
To test the code without a raspberry pi, elixir offers the possibility to run tests for the code. In these test every possibilty what may happens in reality is tested. But the Code for the test is not written automatically and it won't be compiled on the SD Card for the raspberry pi. 

# LEDs
On the website the user enters the max brightness for the LEDs. The grow box process will adjust the duty-cycle of the signal. A day-night-cycle will control the leds so they turn automatically on and off at 6:00 o Clock in the morning and 8:00 o Clock in the evening. 

# used parts
1x Raspberry Pi 3B+
1x SD Card
3x LM317D
3x PT100
3x 56Ω resistor
1x L293D
1x MCP3008
1x 40.52 relay
1x 1N4148
3x small pumps
1x large pump
1x power supply (12V / 60W)
1x TDS sensor
1x pH sensor
1x TL084
1x Step Down Converter (12V / 5V)
3x capacitor (10uF)
clamps and wires


read analog signal with Raspberry Pi and MCP3008: https://learn.adafruit.com/reading-a-analog-in-and-controlling-audio-volume-with-the-raspberry-pi?view=all
https://dev.to/mnishiguchi/elixir-nerves-potentiometer-with-spi-based-analog-to-digital-converter-25h1
current source with LM317: http://www.netzmafia.de/skripten/hardware/LM317/LM317.html

MCP3008: https://dev.to/mnishiguchi/elixir-nerves-potentiometer-with-spi-based-analog-to-digital-converter-25h1
https://hexdocs.pm/circuits_spi/Circuits.SPI.html

LM293D:
https://www.ti.com/lit/ds/symlink/l293.pdf

