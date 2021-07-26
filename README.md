# IrisTemplateExtractor
Matlab code for extracting iris vector templates.

Uses Masek's iris identification code from his dissertation as a basis. However, several enhancements to the speed and efficiency have been made.

To run the code first add the two subfolders to your Matlab path. Setup a folder for the results at a specified location \<path to parent of results folder>/\<name of dataset>. Within this create three subfolders for Templates, Masks and MaskedTemplates. Then call exportdata(\<path to dataset folder>, \<path to parent of results folder>, \<name of dataset>). This will populate the three subfolders at \<path to parent of results folder>/\<name of dataset> with a json file for each user in the dataset.

The dataset must have a subfolder for each user. Each of these must have a subfolder for 'L' and 'R'. These can be empty or include any number of iris images for that user.

Code to compare the vector templates is provided seperately.

There are a number of parameters throughout the code which may need to be adjusted for each dataset. These include the thresholds for detecting the iris boundaries and the maximum and minimum sizes of the pupil and iris radiuses.

References:

Libor Masek, Peter Kovesi. MATLAB Source Code for a Biometric Identification System Based on Iris Patterns. The School of Computer Science and Software Engineering, The University of Western Australia. 2003.

