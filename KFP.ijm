/*
 * Macro template to process multiple images in a folder
 */

#@ File (label = "Input directory", style = "directory") input
//#@ File (label = "Output directory", style = "directory") output
#@ Integer (label = "Nr. of Channels", style = "number" ) channels

#@ String (label = "File Name", value = "250MOIHPBF_XY02_{iiiii}_") name
#@ String (label = "File suffix", value = ".tif") suffix
#@ boolean (label = "Stitch?", value = "False") stitch
#@ Integer (label = "Grid X", style = "number" ) gridx
#@ Integer (label = "Grid Y", style = "number" ) gridy


// See also Process_Folder.py for a version of this code
// in the Python scripting language.

setBatchMode(true);

//processFolder(input);
separateChannels(input, channels, stitch);
folder = input +"_Processed"+ File.separator + "CH1";


function separateChannels(input, channels, stitch) {
// function description
	filename = name + suffix;
	//Create processing folder
	procFolder = input +"_Processed";
	File.makeDirectory(procFolder);

	print("Created folder:"  + procFolder);

	for (i = 1; i <= channels; i++) {
		// Current channel suffix
		suffix_new = "CH"+i;
		// Folder for a Zstacked individal files 16 bit
		zstack_folder = procFolder + File.separator + suffix_new;

		createDirectory(zstack_folder);
		//File.makeDirectory(zstack_folder);

		print("Created folder:"+zstack_folder);

		//Go through all images with current suffix
		processChannels(input, suffix_new, procFolder);
		if (stitch)
		{
			stitchChannels(zstack_folder, name, gridx, gridy, suffix, suffix_new);
		}


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
}

function stitchChannels(folder, name, gridx, gridy, suffix, suffix_new) {

	stitchedFolder = folder+"_stitched";
	File.makeDirectory(stitchedFolder);

	run("Grid/Collection stitching", "type=[Grid: snake by rows] order=[Right & Down                ] grid_size_x="+gridx+" grid_size_y="+gridy+" tile_overlap=30 first_file_index_i=1 directory="+folder+" file_names="+name+suffix_new+suffix+" output_textfile_name=TileConfiguration.txt fusion_method=[Linear Blending] regression_threshold=0.30 max/avg_displacement_threshold=2.50 absolute_displacement_threshold=3.50 compute_overlap subpixel_accuracy computation_parameters=[Save computation time (but use more RAM)] image_output=[Write to disk] output_directory="+stitchedFolder);


}

function createDirectory(dir) {
    if (!File.isDirectory(dir)) {
        File.makeDirectory(dir);
    }
}

