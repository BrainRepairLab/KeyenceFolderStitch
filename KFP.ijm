/*
 * Macro template to process multiple images in a folder
 */

#@ File (label = "Input directory", style = "directory") input
//#@ File (label = "Output directory", style = "directory") output
#@ Integer (label = "Nr. of Channels", style = "number" ) channels

#@ String (label = "File Name", value = "250MOIHPBF_XY02_{iiiii}_CH1") name
#@ String (label = "File suffix", value = ".tif") suffix
#@ boolean (label = "Stitch?", value = "False") stitch
#@ Integer (label = "Grid X", style = "number" ) gridx
#@ Integer (label = "Grid Y", style = "number" ) gridy


// See also Process_Folder.py for a version of this code
// in the Python scripting language.

setBatchMode(true);

//processFolder(input);
//separateChannels(input, output, channels);
folder = input +"_Processed"+ File.separator + "CH1";

filename = name + suffix;
//if (stitch=="True") {
	stitchChannels(folder, filename, gridx, gridy)
//}




function separateChannels(input, channels) {
// function description

	//Create processing folder
	procFolder = input +"_Processed";
	File.makeDirectory(procFolder);
	print("Created folder:"  + procFolder);

	for (i = 1; i <= channels; i++) {
		suffix_new = "CH"+i;
		//new_folder = (output + File.separator + suffix_new);
		File.makeDirectory(procFolder + File.separator+suffix_new );
		print("Created folder:"+procFolder + File.separator + suffix_new);

		//Go through all images with current suffix
		processChannels(input, suffix_new, procFolder);


	}


}

function processChannels(input, suffix_new, procFolder) {
	list = getFileList(input);

	list = Array.sort(list);
	destination = procFolder+File.separator+suffix_new;

//	print("destination:"+destination);
	for (i = 0; i < list.length; i++) {

		if(endsWith(list[i], suffix_new+suffix)){
//			print(list[i]);
			open(input+ File.separator +list[i]);
			run("Z Project...", "projection=[Max Intensity]");
			saveAs(suffix, destination+ File.separator +list[i]);


	}
}

function stitchChannels(folder, filename, gridx, gridy) {

	stitchedFolder = folder+"_stitched";
	File.makeDirectory(stitchedFolder);

	run("Grid/Collection stitching", "type=[Grid: snake by rows] order=[Right & Down                ] grid_size_x="+gridx+" grid_size_y="+gridy+" tile_overlap=30 first_file_index_i=1 directory="+folder+" file_names="+filename+" output_textfile_name=TileConfiguration.txt fusion_method=[Linear Blending] regression_threshold=0.30 max/avg_displacement_threshold=2.50 absolute_displacement_threshold=3.50 compute_overlap subpixel_accuracy computation_parameters=[Save computation time (but use more RAM)] image_output=[Write to disk] output_directory="+stitchedFolder);
}
