<html>



<h1> Scripts for Training animals to perform two alternative forced choice frequency discrimination tasks </h1>

<body>

<h2>Training Stages: </h2>
<ul>
	<l1>
	 1. <b>Conditioning:</b> Mice are initially trained to respond to a sound. Ie a sound between the two mean frequencies that will define
	 the sound classes is played; then some time later (300-700ms), reward is delivered automatically. May use click instead of central
	 pure tone
	    <ul>
	          <li>
	          	May in some cases use clicks instead of pure tones
	          </li>
	          <li>
	          	Training stage 1.1 may be that they have to lick in a 
	          	window following the onset of the sound, but this is not
	          	certrain
	          </li>
	    </ul>
	</l1>
	
	<l1>
	 2. <b>Major Pretraining Step</b>: Mice are trained to dicriminate the two sounds. Each sound is played and mice receive water immediately and automatically if they lick the correct side. If they lick the incorrect side, reward is delivered automatically
	 after ~900ms. However, if they do not immediately lick the correct side, the inter-trial interval is approx doubled. There are error correction trials.
	</l1>


</ul>


<h2> General Notes  </h2>

<h3> Stimulus Presentation </h3>

Stimuli are all stochastic. They are drawn from either log-normal (MATLAB code) or log-T (Python) Distributions, with variance of 1/6 of an octave. They are also roved. The aim of this is to be able to estimate during learning sensitivity to stimuli as well as have stimulus variance present to look at neural population responses when the animals are behaving

<h3> Notes for self </h3>

<b>Potential problems</b>

<h4> First Pretraining Step </h4>

<ul>

  <li>
  Mice don't lick at all. 
  </li>
  
  <li>
  Mice don't learn to lick selectively during presentation of the water
  </li>
  



<h4> Second Pretraining (Training) Step </h4>

<ul>

  <li>
  Mice respond only to one side with very strong bias (-> error correction trials)
  </li>
  
  <li>
  Mice lose motivation and stop responding entirely (should include manual reward delivery!!!!)
  </li>
  
  <li>
  Mice performance does not improve
  </li>

</body>

</html>
