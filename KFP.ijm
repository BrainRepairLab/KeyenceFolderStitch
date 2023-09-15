/*
 * Macro template to process multiple images in a folder and optionally stitch them.
 */

// User-defined input parameters for the script.
#@ File (label = "Input directory", style = "directory") input
#@ Integer (label = "Nr. of Channels", style = "number" ) channels
#@ String (label = "File Name", value = "250MOIHPBF_XY02_{iiiii}_") name
#@ String (label = "File suffix", value = ".tif") suffix
#@ boolean (label = "Stitch?", value = "False") stitch
#@ Integer (label = "Grid X", style = "number" ) gridx
#@ Integer (label = "Grid Y", style = "number" ) gridy

// Turn on batch mode for faster processing without UI updates.
setBatchMode(true);

// Separate channels based on user input.
separateChannels(input, channels, stitch);
folder = input + "_Processed" + File.separator + "CH1";

// Function to separate the channels of the images.
function separateChannels(input, channels, stitch) {
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
        // If user has opted for stitching, execute stitch operation.
        if (stitch) {
            stitchChannels(zstack_folder, name, gridx, gridy, suffix, suffix_new);
        }
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
function stitchChannels(folder, name, gridx, gridy, suffix, suffix_new) {
    // Define folder for stitched output.
    stitchedFolder = folder + "_stitched";
    createDirectory(stitchedFolder);

    // Run the stitching command.
    run("Grid/Collection stitching", "type=[Grid: snake by rows] order=[Right & Down                ] grid_size_x=" + gridx + " grid_size_y=" + gridy + " tile_overlap=30 first_file_index_i=1 directory=" + folder + " file_names=" + name + suffix_new + suffix + " output_textfile_name=TileConfiguration.txt fusion_method=[Linear Blending] regression_threshold=0.30 max/avg_displacement_threshold=2.50 absolute_displacement_threshold=3.50 compute_overlap subpixel_accuracy computation_parameters=[Save computation time (but use more RAM)] image_output=[Write to disk] output_directory=" + stitchedFolder);
}

// Utility function to create a directory if it doesn't already exist.
function createDirectory(dir) {
    if (!File.isDirectory(dir)) {
        File.makeDirectory(dir);
    }
}
