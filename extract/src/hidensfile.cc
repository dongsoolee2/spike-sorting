/* hidensfile.cc
 *
 * Implementation of class representing HDF file storing data
 * recorded on Hidens arrays.
 *
 * (C) 2015 Benjamin Naecker bnaecker@stanford.edu
 */

#include "hidensfile.h"

hidensfile::HidensFile::HidensFile(std::string name) : datafile::DataFile(name)
{
}

hidensfile::HidensFile::~HidensFile()
{
}

void hidensfile::HidensFile::data(size_t start, size_t end, arma::Mat<uint8_t>& out)
{
	/* Verify input and resize return array */
	if (end <= start) {
		std::cerr << "Requested sample range is invalid: " << start << " - " 
			<< end << std::endl;
		throw std::logic_error("Requested sample range invalid");
	}
	size_t requestedSamples = end - start;
	out.set_size(requestedSamples, nchannels());

	/* Select hyperslab from the file */
	hsize_t spaceOffset[datafile::DATASET_RANK] = {0, start};
	hsize_t spaceCount[datafile::DATASET_RANK] = {nchannels(), requestedSamples};
	dataspace.selectHyperslab(H5S_SELECT_SET, spaceCount, spaceOffset);
	if (!dataspace.selectValid()) {
		std::cerr << "Dataset selection invalid" << std::endl;
		std::cerr << "Offset: (0, " << start << ")" << std::endl;
		std::cerr << "Count: (" << nchannels() << ", " << requestedSamples << ")" << std::endl;
		throw std::logic_error("Dataset selection invalid");
	}

	/* Define memory dataspace */
	hsize_t mdims[datafile::DATASET_RANK] = {nchannels(), requestedSamples};
	H5::DataSpace mspace(datafile::DATASET_RANK, mdims);
	hsize_t moffset[datafile::DATASET_RANK] = {0, 0};
	hsize_t mcount[datafile::DATASET_RANK] = {nchannels(), requestedSamples};
	mspace.selectHyperslab(H5S_SELECT_SET, mcount, moffset);
	if (!mspace.selectValid()) {
		std::cerr << "Memory dataspace selection invalid" << std::endl;
		std::cerr << "Count: (" << requestedSamples << ", " << nchannels() << ")" << std::endl;
		throw std::logic_error("Memory dataspace selection invalid");
	}

	dataset.read(out.memptr(), H5::PredType::STD_U8LE, mspace, dataspace);
}

void hidensfile::HidensFile::data(
		size_t channel, size_t start, size_t end, arma::Col<uint8_t>& out)
{
	/* Verify input and resize return array */
	if (end <= start) {
		std::cerr << "Requested sample range is invalid: " << start << " - " 
			<< end << std::endl;
		throw std::logic_error("Requested sample range invalid");
	}
	size_t requestedSamples = end - start;
	out.set_size(requestedSamples);

	/* Select hyperslab from the file */
	hsize_t spaceOffset[datafile::DATASET_RANK] = {channel, start};
	hsize_t spaceCount[datafile::DATASET_RANK] = {1, requestedSamples};
	dataspace.selectHyperslab(H5S_SELECT_SET, spaceCount, spaceOffset);
	if (!dataspace.selectValid()) {
		std::cerr << "Dataset selection invalid" << std::endl;
		std::cerr << "Offset: (" << channel << ", " << start << ")" << std::endl;
		std::cerr << "Count: (" << nchannels() << ", " << requestedSamples << ")" << std::endl;
		throw std::logic_error("Dataset selection invalid");
	}

	/* Define memory dataspace */
	hsize_t mdims[datafile::DATASET_RANK] = {1, requestedSamples};
	H5::DataSpace mspace(datafile::DATASET_RANK, mdims);
	hsize_t moffset[datafile::DATASET_RANK] = {0, 0};
	hsize_t mcount[datafile::DATASET_RANK] = {1, requestedSamples};
	mspace.selectHyperslab(H5S_SELECT_SET, mcount, moffset);
	if (!mspace.selectValid()) {
		std::cerr << "Memory dataspace selection invalid" << std::endl;
		std::cerr << "Count: (" << requestedSamples << ", " << nchannels() << ")" << std::endl;
		throw std::logic_error("Memory dataspace selection invalid");
	}

	dataset.read(out.memptr(), H5::PredType::STD_U8LE, mspace, dataspace);
}
