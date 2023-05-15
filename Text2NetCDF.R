library(ncdf4)

## The file name contains lon/lat
## Example of lon 68.375, lat 8.125 and the file names like 68375_08125.txt with full path
filepath <- read.csv("/AR6/India/Path_for_Pr_nc_files.csv")

foldlist <- nrow(na.exclude(filepath))

for(foldername in 1:foldlist){

	outfilename = filepath [foldername,2]
	scrfolder = filepath [foldername,1]
		
	filelist = list.files(scrfolder,'*.txt',full.names=T)
	initdat <- read.delim(filelist[1],header=T,stringsAsFactors=F)
	nodays <- length(initdat[,1])

#	foldername <- unlist(strsplit(basename(scrfolder), '_'))[[1]]

	xvals <- seq(68.375, 97.125, 0.25)
	yvals <- seq(8.125, 36.875, 0.25) 
	nx <- length(xvals)
	ny <- length(yvals)
	lon1 <- ncdim_def("longitude", "degrees_east", xvals)
	lat2 <- ncdim_def("latitude", "degrees_north", yvals)

	time <- ncdim_def("time", "days since 1951-01-01 00:00:00", 0:(nodays-1), unlim=TRUE)
	mv <- -999 #missing value to use
	var_temp <- ncvar_def("pr", "kg m-2 s-1", list(lon1, lat2, time), longname="Precipitation", mv) 
	##var_temp <- ncvar_def(var name, unit, dim, longname, missing value)

	#print(Sys.time())
	ncnew <- nc_create(outfilename, list(var_temp))
	#print(Sys.time())

	#print(paste("The file has", ncnew$nvars,"variables"))
	#print(paste("The file has", ncnew$ndim,"dimensions"))

	for(flname in filelist){

		latlon <- unlist(strsplit(sub('.txt','',basename(flname)),'_'))

		lon <- as.numeric(paste0(latlon[1],'5'))/1000
		lat <- as.numeric(paste0(latlon[2],'5'))/1000

		lonloc<-which(xvals==lon)
		latloc<-which(yvals==lat)

		data<-read.delim(flname,header=T,stringsAsFactors=F)

		ncvar_put(ncnew, var_temp, data[,1]/86400, start=c(lonloc,latloc,1), count=c(1,1,nodays))
		nc_sync( ncnew ) 
	}

	# Don't forget to close the file
	nc_close(ncnew)
	print(Sys.time())
}
