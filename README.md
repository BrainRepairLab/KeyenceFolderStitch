# Keyence Image Processor

Image Processing Macro

This repository contains a macro script for ImageJ designed to process and optionally stitch multiple images in a directory based on their channels.

## **Overview**

The macro provides functionalities to:

Separate images based on specified channels.
Process these images using max intensity projection.
Stitch these processed images together in a grid configuration (optional).
Prerequisites

## Software Requirement: 
Ensure you have either ImageJ or Fiji installed.

## Usage

Launch ImageJ or Fiji.
Navigate to Plugins > Macros > Run....
Select the provided macro script from your directory.
Input the required parameters in the dialog box:

Input Directory: Directory containing your images.

Nr. of Channels: Number of channels in your images.

File Name: Base name structure of your image files.

File Suffix: The file extension (e.g., .tif).

Stitch?: Choose if you wish to stitch the images after processing.

Grid X and Grid Y: Specify the grid dimensions for stitching (if stitching is selected).

Click OK to run the macro.

Directory Structure After Execution After processing:

A _Processed folder is created in the main directory.

Inside, individual folders for each channel like CH1, CH2 etc. can be found.

If stitching is chosen, each channel directory will also contain a CHx_stitched folder housing the stitched images.

## Customizing the Macro

The macro is generalized but can be tailored to specific needs. Modify it using a text editor or the editor within ImageJ/Fiji.

## License

This macro is distributed under the MIT License. See LICENSE file for more information.

## Acknowledgments

A big thank you to the ImageJ community and its developers for their resources and continuous support.
Kudos to OpenAI for its advanced language model capabilities.