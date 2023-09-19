/*
 * Macro template to process multiple images in a folder and optionally stitch them.
 */

// User-defined input parameters for the script.
#@ File (label = "Input directory", style = "directory") input

#@ String (label = "Project Name", value = "MT") projects
//#@ Integer (label = "Animal Number", style = "number" ) animal

#@ Integer (label = "Nr. of Channels", value = "2" ) channels
//for (i = 1; i <= channels; i++){

//#@ String (label = "Channel", value = "250MOIHPBF_XY02_{iiiii}_") channel+i



#@ String (label = "File Name to process", value = "250MOIHPBF_XY02_{iiiii}_") name
#@ String (label = "Final file name", value = "R01_S1-3-2_Ab1_Ab2") finalname
#@ String (label = "File suffix", value = ".tif") suffix
#@ boolean (label = "Separte channels", value = "True") separate
#@ boolean (label = "Stitch", value = "False") stitch
#@ Integer (label = "Stitch Ch:", style = "number" ) stitch_channel

#@ Integer (label = "Grid X", style = "number" ) gridx
#@ Integer (label = "Grid Y", style = "number" ) gridy

#@ boolean (label = "Convert to 8Bit", value = "False") eightbit

// Turn on batch mode for faster processing without UI updates.
setBatchMode(true);

// Separate channels based on user input.
if (separate) {

separateChannels(input, channels, stitch, eightbit, finalname);
}


if (stitch) {

}
	filename = name + suffix;
	procFolder = input + "_Processed";
 // Loop through the channels.
//    for (i = 1; i <= channels; i++) {

	    // Current channel suffix (e.g., CH1, CH2, etc.).
	    suffix_new = "CH" + stitch_channel;
	    print(suffix_new);
	    // Directory for storing Z-stacked individual files.
	    folder = procFolder + File.separator + suffix_new;
		print(folder);
	    // Define folder for stitched output.
    	output = folder + "_stitched";
   		createDirectory(output);

    	stitchChannels(folder, name, gridx, gridy, suffix, suffix_new, eightbit, finalname, output);
//}





// Function to separate the channels of the images.
function separateChannels(input, channels, stitch, eightbit, finalname) {
    // Construct the filename from user input.
    filename = name + suffix;
    // Create main processing directory.
    procFolder = input + "_Processed";
    createDirectory(procFolder);
    print("Created folder:" + procFolder);

    // Loop through the channels.
    for (i = 1; i <= channels; i++) {
        // Current channel suffix (e.g., CH1, CH2, etc.).
        suffix_new = "CH" + i;
        // Directory for storing Z-stacked individual files.
        zstack_folder = procFolder + File.separator + suffix_new;
        createDirectory(zstack_folder);
        print("Created folder:" + zstack_folder);

        // Process images for the current channel.
        processChannels(input, suffix_new, procFolder);


    }
}

// Function to process images by channel.
function processChannels(input, suffix_new, procFolder) {
    list = getFileList(input);
    list = Array.sort(list);  // Sort the file list.
    destination = procFolder + File.separator + suffix_new;

    // Loop through each file in the directory.
    for (i = 0; i < list.length; i++) {
        // If file matches the current channel and suffix, process it.
        if (endsWith(list[i], suffix_new + suffix)) {
            open(input + File.separator + list[i]);
            // Apply max intensity projection.
            run("Z Project...", "projection=[Max Intensity]");
            // Save the processed image.
            saveAs(suffix, destination + File.separator + list[i]);
        }
    }
}

// Function to stitch processed images.
function stitchChannels(folder, name, gridx, gridy, suffix, suffix_new, eightbit, finalname, output) {

	// The default name of the stitched file
	default_name = "img_t1_z1_c1";

    // Run the stitching command.
    run("Grid/Collection stitching", "type=[Grid: snake by rows] order=[Right & Down                ] grid_size_x=" + gridx + " grid_size_y=" + gridy + " tile_overlap=30 first_file_index_i=1 directory=" + folder + " file_names=" + name + suffix_new + suffix + " output_textfile_name=TileConfiguration.txt fusion_method=[Linear Blending] regression_threshold=0.30 max/avg_displacement_threshold=2.50 absolute_displacement_threshold=3.50 compute_overlap subpixel_accuracy computation_parameters=[Save computation time (but use more RAM)] image_output=[Write to disk] output_directory=" + output);

	if (eightbit) {

		open(output + File.separator + default_name);
		saveAs(suffix, output + File.separator + finalname + "_" + suffix_new+ "_stitched_16bit");

		run("8-bit");
		saveAs(suffix, output + File.separator + finalname + "_" + suffix_new+ "_stitched_8bit");
		File.delete(output + File.separator + default_name);

	}
	else
	{
		open(output + File.separator + default_name);
		saveAs(suffix, output + File.separator + finalname + "_" + suffix_new+ "_stitched_16bit");
		File.delete(output + File.separator + default_name);
	}

// Utility function to create a directory if it doesn't already exist.
function createDirectory(dir) {
    if (!File.isDirectory(dir)) {
        File.makeDirectory(dir);
    }
}
