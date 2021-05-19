sw3Build <- function(masterRaster, tsaDirs, years){
  # this is the table that will get filled with all the firest
  fireDistsDT <- data.table(pixelIndex = integer(), year = integer(), events = integer())
  cutDistsDT <- data.table(pixelIndex = integer(), year = integer(), events = integer())

  for(i in 1:length(years)){
    # the files have the same names and are in the same order in the 5 tsa folders
    distTifs <- grep(years[i], list.files(list.dirs('inputs')[tsaDirs[1]])[-c(1:9)])
    # fire = distTifs[1]
    # cut = distTifs[2]
    fireList <- list()
    cutList <- list()
    for(j in 1:length(tsaDirs)){
      fireList[[j]] <- raster::raster(file.path(list.dirs('inputs')[tsaDirs[j]],
                                                list.files(list.dirs('inputs')[tsaDirs[j]])[-c(1:9)][distTifs[1]]))
      cutList[[j]] <- raster::raster(file.path(list.dirs('inputs')[tsaDirs[j]],
                                               list.files(list.dirs('inputs')[tsaDirs[j]])[-c(1:9)][distTifs[2]]))
    }

    # put the 5 rasters together
    fireList$fun <- mean
    fireList$na.rm <- TRUE
    fireRast0 <- do.call(mosaic, fireList)
    fireRast1yr <- postProcess(fireRast0,
                               rasterToMatch = masterRaster)
    fireDT1yr <- data.table(pixelIndex = 1:ncell(fireRast1yr), year = years[i], events = fireRast1yr[])
    fireDistsDT <- rbindlist(list(fireDistsDT,fireDT1yr[!is.na(events)]))

    cutList$fun <- mean
    cutList$na.rm <- TRUE
    cutRast0 <- do.call(mosaic, cutList)
    cutRast1yr <- postProcess(cutRast0,
                              rasterToMatch = masterRaster)
    cutDT1yr <- data.table(pixelIndex = 1:ncell(cutRast1yr), year = years[i], events = cutRast1yr[])
    # cut events = 2
    cutDT1yr[!is.na(events)]$events <- 2
    cutDistsDT <- rbindlist(list(cutDistsDT,cutDT1yr[!is.na(events)]))
  }

  distList <- rbindlist(list(fireDistsDT, cutDistsDT))
  return(distList)
}
