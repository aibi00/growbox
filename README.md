# growbox
This will be the code for my diploma thesis. I'm building my own growbox with my friends. At the end of this documentation you can find all the links that helped me. You can find this documentation in the pdf file which will be added.  

# description
For this project I will use a Raspberry Pi 3. The programming language is Elixir. For more informations about Elixir, you can visit the homepage. https://elixir-lang.org/.

In our growbox are a few sensors to get temperature, water levels and quality and flow rate. The inputs can be seen on a website, which is also running on the Pi. A camera will take photos and make a time-lapse video. In total we will have four pumps. Three of them will be in small tanks with water, nutrient solution and a liquid to bring down the pH value of the water in the larger tank. In the larger tank all liquids are mixed together and the fourth pump will water the plants with it.

# hat
To read all these sensors and control the pumps I will design my own Raspberry Pi Header. I'll design it with the software EAGLE from autodesk. On the board will be three current sources, an ADC, a circuit to control a relais and several clamps.

# measuring the temperatur
To control the leds, we have to know their temperatur. For this i will use three PT100. A PT100 is a temperatur-dependent resistor and with the formula you can calulate every valua at a temperatur. In electrical measuring technology only voltage can be measured. 

So how do we get a voltage from our PT100?
With a constant current source through the PT100. But how many amps do we need? The base for this project is a Raspberry Pi 3 and he runs with 5V but his GPIOs can only drive 3.3V and he doesn't have any ADCs, so we need one between the PT100 and Raspberry Pi. 

The ADC i chose is the MCP3008. He ususally runs on 5V but we don't want to hurt the Raspberry Pi, so the ADC will be powered with 3.3V. The MCP3008 has 8 analog inputs and 10 bit resolution. 

The leds usually have a operation temperatur of 85°C and a total maximum temperatur of 105°C. I want to fully use the 10 bit and 3.3V, so i set the limit to 120°C.
At 120°C the PT100 has a resitance value of 146.07 Ω. 

3.3V / 146.07 = 22.438mA

This is the constant current i need. Now i just need to design and customize a constant current source. It took me some time but i finally found a simple and temperature resitant source. The current source with LM317 is simple to calculate and it is cheap. From the link below i calculated the resistor to get the needed constant current. 
(Iout = 1.25 / R) => R = 1.25 / Iout = 55.709 Ω. 

In order not to falsify the measurement, an impedance converter is placed between the ADC and PT100. 
Temperatur measurement is ready to programm. 

# large pump
A large pump will keep the plants wet with nutritious water, but the Raspberry Pi can't drive the pump so i need a small circuit with a relay, a transistor and a free-wheeling diode. The relay that is used is the 40.52. When you start the growbox, you have to enter two intervals on the website. First interval is the time how long you want to water the plants and the second one is the time between watering. 

# small pumps
In the growbox will be four small tanks with pumps in it. In the first tank will be normal water to fill up the large tank. One small tanks will be filled with a pH-value rising liquid and the other one will be filled with a pH-value sinking liquid. The acidity will be measured by a special pH-sensor. In the fourth tank will be the nutritious solution for the plants. All tanks are equipped with swim-switches. A notification will be shown on the website if one switch report not enough liquid. Every pump has its own logic.

# swim switches
In total there will be five switches to check fluid level. 

# website
The website is runnig on the rasberry pi and it will show some data in graphs like the temperatur, pH-value, nutrient solution. The user can switch manually switch on or off the large pump and leds. On the website the user can enter the intervals for the pump and the brightness for the plants. A camera will take every 30mins a photo and at the end of the growing process the photos will be edited together to a time-lapse-video. 






read analog signal with Raspberry Pi and MCP3008: https://learn.adafruit.com/reading-a-analog-in-and-controlling-audio-volume-with-the-raspberry-pi?view=all
https://dev.to/mnishiguchi/elixir-nerves-potentiometer-with-spi-based-analog-to-digital-converter-25h1
current source with LM317: http://www.netzmafia.de/skripten/hardware/LM317/LM317.html
