from __future__ import division
import numpy as np
import numpy.random as rnd
import time
import multiprocessing as billiard
import RPi.GPIO as GPIO
import csv
import requests as req
import pygame
import sys
import random
from pygame.locals import *


print "Im online :)"




# Sounds are played every few seconds, determined by variables that specify wait-time. Reward is automatically delivered
# after 700ms. Sound is a pure tone in the centre of the frequency space.
#
#
#
#
#
#

#-----------------------------------------------------------------
#Initialise function for sending data to server

#Figure out appropriate IP address based on the server
pi_IP = [(s.connect(('8.8.8.8', 80)), s.getsockname()[0], s.close()) for s in [socket.socket(socket.AF_INET, socket.SOCK_DGRAM)]][0][1]
pi_ID = str(int(pi_IP[-3:])-100)


def send_data(load):

    headers = {'User-Agent': 'Mozilla/5.0'}
    link = 'http://192.168.0.99:8000/getData/' + pi_ID + '/get_PiData/'

    session = req.Session()
    r1 = session.get(link,headers=headers)

    link1 = 'http://192.168.0.99:8000/getData/' + pi_ID + '/write_PiData/'


    payload = {'piData':load,'csrfmiddlewaretoken':r1.cookies['csrftoken']}
    #cookies = dict(session.cookies)
    session.post(link1,headers=headers,data=payload)
    return None




#______________________ Setup RPi.GPIO ____________________________

GPIO.setmode(GPIO.BOARD)

lickL = 36
lickR = 38
GPIO.setup(lickL,GPIO.IN)
GPIO.setup(lickR,GPIO.IN)
GPIO.add_event_detect(lickL,GPIO.RISING)
GPIO.add_event_detect(lickR,GPIO.RISING)


solOpenDur = 0.03
rewL = 35
rewR = 37
GPIO.setup(rewL,GPIO.OUT)
GPIO.setup(rewR,GPIO.OUT)


#___________________ Reward Delivery Helper Functions ____________________

def deliverRew(channel):
    GPIO.output(channel,1)
    time.sleep(solOpenDur)
    GPIO.output(channel,0)

rewProcL = billiard.Process(target=deliverRew,args=(rewL,))
rewProcR = billiard.Process(target=deliverRew,args=(rewR,))


#The mapping is 0 is right response, 1 is left response
def rew_action(side,rewProcR,rewProcL):
    if side==0:
        #time.sleep(0.1)
        rewProcR = billiard.Process(target=deliverRew,args=(rewR,))
        rewProcR.run()
    if side==1:
        #time.sleep(0.1)
        rewProcL = billiard.Process(target=deliverRew,args=(rewL,))
        rewProcL.run()
    LR_target = rnd.randint(2)
    return LR_target

#_____________________________________________________________________________

# Task parameters

# Stimulus frequencies
lowF = 8000
highF = lowF*2**(1.5)
centreFreq = np.logspace(lowF,highF,num=3)[1]
freqs = [highF,lowF]




# Stimulus timing
dur = 0.2 # duration of a sound, in seconds
waittime = 12 #waiting time from moment both spouts have been licked, to presentation of next stimulus

# Experiment structure 
ExpDur = 45*60 #max total duration in seconds

# Reward stuff
rewTotMax = 300 #total number of rewards allowed in one experimental block, before it is aborted

# Other stuff
minILI = 0.05 #minimum inter-lick interval in seconds; for two lick-detections to be considered two seperate licks. Combats switch bounce from hardware
#_____________________________________________________________________________

#initialise the sound mixer
pygame.mixer.pre_init(96000,-16,1,256) #if jitter, change 256 to different value
pygame.init()

#_____________________________________________________________________________

# choose target and initial frequencies
freqs = [6000,24000]
initIdx = 0
initFreq = freqs[initIdx]

#_____________________________________________________________________________
#make sine waves one by one

max24bit = np.array(16777210,dtype='float32')
max16bit = 32766
sR = 96000 # sampling rate = 96 kHz

def gensin(frequency=12000, duration=dur, sampRate=sR, edgeWin=0.01):
    cycles = np.linspace(0,duration*2*np.pi,num=duration*sampRate)
    wave = np.sin(cycles*frequency, dtype='float32')
    
    #smooth sine wave at the edges
    numSmoothSamps = int(edgeWin*sR)
    wave[0:numSmoothSamps] = wave[0:numSmoothSamps] * np.cos(np.pi*np.linspace(0.5,1,num=numSmoothSamps))**2
    wave[-numSmoothSamps:] = wave[-numSmoothSamps:] * np.cos(np.pi*np.linspace(1,0.5,num=numSmoothSamps))**2
    wave = np.round(wave*max16bit)
    
    return wave.astype('int16')

#_____________________________________________________________________________

# make one big list with all sine waves and prepare those sounds
#snd_list = [gensin(frequency=f) for f in freqs]
#snd_Tpl_All = [pygame.sndarray.make_sound(SOUND.astype('int16')) for SOUND in snd_list]

# prepare first sound to play
snd_Tpl = snd_Tpl_All[initIdx]


def get_sound(idx):
	volume = np.random.randint(40,140)/100
	freq = np.random.lognormal(mean=np.log(freqs[idx]),sigma=1/24,size=1)
	sndArr = gensin(frequency=freq)
	SOUND = sndArr * volume
	snd = pygame.sndarray.make_sound(SOUND.astype('int16'))
	return snd, volume, freq


def play_sound(sound):
    sound.play()


#_____________________________________________________________________________

def data_sender(lickList,rewList,sndList,sendT):

    sndStr = 'sndList:' + '-'.join([str(np.round(entry[0],decimals=3))+entry[1] for entry in sndList])
    lickStr = 'LickList:' + '-'.join([str(np.round(entry[0],decimals=3))+entry[1] for entry in lickList])
    rewStr = 'rewList:' + '-'.join([str(np.round(entry[0],decimals=3))+entry[1] for entry in rewList])
    sendStr = ','.join([rewStr,sndStr,lickStr])
            
    sendProc = billiard.Process(target=send_data,args=(sendStr,))
    sendProc.start()
    print 'seeeeeending', (time.time()-start-soundT)
    #send_data(sendStr)
    sendT = time.time()
    sndList = []; lickList = []; rewList = [];
    return lickList, rewList,sndList, sendT




#_____________________________________________________________________________
# START of the Experiment

#initialize data lists (for licks and tones)
lickList = [] #[[soundIdx],[lickID],[lickT]]
soundList = [] #[[soundIdx],[soundFreq],[soundT]]

# initialize counters
soundIdx = 0
rewTot = 0

start = time.time() #THIS IS THE T=0 POINT

lickLst = []
rewList = []
sndList = []

sendT = time.time()
lickT = time.time()
prevL = time.time()
delivered = True
soundT = time.time()-start
# Do the whole experiment in one big LOOP over each sound
rewT = time.time() - start
LR_target = np.random.randint(0,2)

minW = 4; maxW = 8
waittime = np.random.randint(minW,maxW)


while time.time() - start < ExpDur and rewTot <= rewTotMax:

	#if 5 seconds have elapsed since the last data_send
	if (time.time()-sendT>5):
		lickList, rewList,sndList, sendT = data_sender(lickList,rewList,sndList,sendT)

    
    # if the time to timeout has elapsed, play the next
    # sound and deliver the next reward
	if (time.time()-start-soundT)>waittime:
		print 'sound'
		#Play target sound
		soundT = time.time() - start
		soundId = freqs[LR_target]
		snd, vol, freq = get_sound(LR_target)
		play_sound(snd) #play the sound
		sndList.append([time.time()-start,'_'+'S:'+str(LR_target)+'F:'+str(freq)+'V:'+str(vol)])
		waittime = np.random.randint(minW,maxW)

		delivered=False
	
	# 
	if ((time.time()-start-soundT)>0.7 and delivered==False):
		delivered=True
		rewT = time.time() - start
		rewList.append([rewT,'_'+str(['R' if LR_target==0 else 'L'][0])])
		LR_target = rew_action(LR_target,rewProcR,rewProcL)
		
	

	# detect the licks
	if (GPIO.event_detected(lickL)):

	    if (time.time()-prevL)>minILI:
			lickT = time.time()
			lickList.append([lickT - start,'L'])

			prevL = time.time()
	    else:
			prevL = time.time()

	if (GPIO.event_detected(lickR) ):

	    if (time.time()-prevL)>minILI:
			lickT = time.time()
			lickList.append([lickT - start,'R'])

			prevL = time.time()
	    else:
			prevL = time.time()
                

