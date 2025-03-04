
### DEFINE MODULE ----

defineModule(sim, list(
  name = "CBM_dataPrep_RIA",
  description = "CBM data preparation module for the RIA study area",
  version = list(SpaDES.core = "1.0.2", CBM_dataPrep_RIA = "0.0.2"),
  authors = c(
    person("Celine", "Boisvenue", email = "Celine.Boisvenue@nrcan-rncan.gc.ca", role = c("aut", "cre")),
    person("Susan",  "Murray",    email = "susan.murray@nrcan-rncan.gc.ca",     role = "ctb")
  ),
  timeunit = "year",
  #documentation = list("CBM_dataPrep_RIA.Rmd"),
  reqdPkgs = list(
    "data.table", "sf", "terra",
    "reproducible (>=2.1.2)" ,
    "PredictiveEcology/CBMutils@development (>=0.0.7.9017)",
    "PredictiveEcology/LandR@development"
  ),
  parameters = rbind(
    defineParameter(".useCache", "logical", TRUE, NA, NA,
                    "Should caching of events or module be used?"),
    defineParameter("resampling", "character", default = "mode", NA, NA,
                    desc = "Raster resampling method")
  ),
  inputObjects = bindrows(
    expectsInput(
      objectName = "dbPath", objectClass = "character", desc = NA, sourceURL = NA), # FROM DEFAULTS
    expectsInput(
      objectName = "dMatrixAssociation", objectClass = "data.frame", desc = NA, sourceURL = NA), # FROM DEFAULTS
    expectsInput(
      objectName = "spinupSQL", objectClass = "dataset", desc = NA, sourceURL = NA), # FROM DEFAULTS
    expectsInput(
      objectName = "species_tr", objectClass = "dataset", desc = NA, sourceURL = NA), # FROM DEFAULTS
    expectsInput(
      objectName = "userGcM3", objectClass = "data.frame",
      sourceURL = "https://drive.google.com/file/d/1BYHhuuhSGIILV1gmoo9sNjAfMaxs7qAj",
      desc = "Table summarizing growth curve volumes with columns: `gcids`, `Age`, `MerchVolume`."),
    expectsInput(
      objectName = "canfi_species", objectClass = "data.frame",
      desc = paste("File containing the possible species in the Boudewyn table.",
                   "Note that if Boudewyn et al. added species, this should be updated.",
                   "Also note that such an update is very unlikely."),
      sourceURL = "https://docs.google.com/spreadsheets/d/1YpJ9MyETyt1LBFO81xTrIdbhjO7GoK3K/"),
    expectsInput(
      objectName = "canfi_speciesURL", objectClass = "character",
      desc = "URL for canfi_species"),
    expectsInput(
      objectName = "userGcM3URL", objectClass = "character",
      desc = "URL for userGcM3"),
    expectsInput(
      objectName = "masterRaster", objectClass = "SpatRaster",
      desc = "Raster has NAs where there are no species and the pixel groupID where the pixels were simulated. It is used to map results",
      sourceURL = "https://drive.google.com/file/d/1h7gK44g64dwcoqhij24F2K54hs5e35Ci"),
    expectsInput(
      objectName = "masterRasterURL", objectClass = "character",
      desc = "URL for `masterRaster` - optional, need this or a `masterRaster` object."),
    expectsInput(
      objectName = "ageRaster", objectClass = "SpatRaster",
      sourceURL = "https://pub.data.gov.bc.ca/datasets/02dba161-fdb7-48ae-a4bb-bd6ef017c36d/2015/VEG_COMP_LYR_L1_POLY_2015.gdb.zip",
      desc = paste(
        "Spatial data source from which stand ages can be extracted.",
        "The default is BC VRI data from 2015"
      )),
    expectsInput(
      objectName = "ageRasterURL", objectClass = "character",
      desc = "URL for ageRaster"),
    expectsInput(
      objectName = "gcIndexRaster", objectClass = "SpatRaster",
      desc = "Raster giving the growth curve value for each pixel",
      sourceURL = "https://drive.google.com/file/d/1LXSX8M46EnsTCM3wGhkiMgqWcqTubC12"),
    expectsInput(
      objectName = "gcIndexRasterURL", objectClass = "character",
      desc = "URL for gcIndexRaster - optional, need this or a ageRaster"),
    expectsInput(
      objectName = "gcMeta", objectClass = "data.frame",
      sourceURL = "https://drive.google.com/file/d/1YmQ6sNucpEmF8gYkRMocPoeKt2P26ZiX",
      desc = "Table of metadata about the growth curves in 'gcIndexRaster'"),
    expectsInput(
      objectName = "gcMetaURL", objectClass = "character",
      desc = "URL for gcMeta"),
    expectsInput(
      objectName = "spuLocator", objectClass = "sf|SpatRaster",
      desc = paste(
        "Spatial data source from which spatial unit IDs can be extracted.",
        "An output of CBM_defaults.")),
    expectsInput(
      objectName = "ecoLocator", objectClass = "sf|SpatRaster",
      desc = paste(
        "Spatial data source from which ecozone IDs extracted.",
        "An output of CBM_defaults.")),
    expectsInput(
      objectName = "disturbanceRasters", objectClass = "character",
      sourceURL = c(
        fire    = "https://drive.google.com/file/d/1kxCL-i311yd3cS7QDQ2GwHHtyQFiiXoo",
        harvest = "https://drive.google.com/file/d/1m7mjcx5Sz--RB7x4N3cPYpGkfmxX8KPB"
      ),
      desc = paste(
        "Required input to CBM_core.",
        "If not specified elsewhere, the default source URLs are provided.",
        "The defaults were made from the Landsat-derived annual fire and harvest layers",
        "as described in: ",
        "Hermosilla, T., M.A. Wulder, J.C. White, N.C. Coops, G.W. Hobart, L.B. Campbell, (2016).",
        "Mass data processing of time series Landsat imagery: pixels to data products for forest monitoring. International Journal of Digital Earth. 9(11), 1035-1054."
      )),
    expectsInput(
      objectName = "disturbanceRastersURL", objectClass = "character",
      desc = "URL for disturbanceRasters"),
    expectsInput(
      objectName = "userDist", objectClass = "data.table",
      sourceURL = "https://drive.google.com/file/d/1Gr_oIfxR11G1ahynZ5LhjVekOIr2uH8X",
      desc = paste(
        "Table defines the values present in the disturbance rasters.",
        "This will be matched with CBM-CFS3 disturbances to create the 'mySpuDmids' table.",
        "Required if the user has provided non-default disturbanceRasters",
        "and the CBM_core input 'mySpuDmids' is not provided elsewhere."),
      columns = c(
        rasterID   = "ID links to pixel values in the disturbance rasters",
        wholeStand = "Specifies if the whole stand is disturbed (1 = TRUE; 0 = FALSE)",
        name       = "Disturbance name (e.g. 'Wildfire')"
      )),
    expectsInput(
      objectName = "userDistURL", objectClass = "character",
      desc = "URL for userDist"),
  ),

  outputObjects = bindrows(
    createsOutput(
      objectName = "allPixDT", objectClass = "data.table",
      desc = "Table summarizing raster input data with 1 row for every 'masterRaster' pixel (including NAs)",
      columns = c(
        pixelIndex      = "'masterRaster' cell index",
        ages            = "Stand ages extracted from input 'ageRaster'",
        spatial_unit_id = "Spatial unit IDs extracted from input 'spuLocator'",
        gcids           = "Growth curve IDs extracted from input 'gcIndexRaster'",
        ecozones        = "Ecozone IDs extracted from input 'ecoRaster'"
      )),
    createsOutput(
      objectName = "spatialDT", objectClass = "data.table",
      desc = paste(
        "Table summarizing raster input data with 1 row for every 'masterRaster' pixel that is not NA",
        "Required input to CBM_vol2biomass and CBM_core."),
      columns = c(
        pixelIndex      = "'masterRaster' cell index",
        pixelGroup      = "Pixel group ID",
        ages            = "Stand ages extracted from input 'ageRaster'",
        spatial_unit_id = "Spatial unit IDs extracted from input 'spuLocator'",
        gcids           = "Growth curve IDs extracted from input 'gcIndexRaster'",
        ecozones        = "Ecozone IDs extracted from input 'ecoRaster'"
      )),
    createsOutput(
      objectName = "level3DT", objectClass = "data.table",
      desc = paste(
        "Table associating pixel groups with their key attributes.",
        "Required input to CBM_vol2biomass and CBM_core."),
      columns = c(
        pixelGroup      = "Pixel group ID",
        ages            = "Stand ages extracted from input 'ageRaster' modified such that all ages are >=3",
        spatial_unit_id = "Spatial unit IDs extracted from input 'spuLocator'",
        gcids           = "Factor of growth curve IDs extracted from input 'gcIndexRaster'",
        ecozones        = "Ecozone IDs extracted from input 'ecoRaster'"
      )),
    createsOutput(
      objectName = "speciesPixelGroup", objectClass = "data.frame",
      desc = paste(
        "Table connecting pixel groups to species IDs.",
        "Required input to CBM_core."),
      columns = c(
        pixelGroup = "Pixel group ID",
        species_id = "Species ID"
      )),
    createsOutput(
      objectName = "curveID", objectClass = "character",
      desc = paste(
        "Column names in 'level3DT' that uniquely define each pixel group growth curve ID.",
        "Required input to CBM_vol2biomass")),
    createsOutput(
      objectName = "ecozones", objectClass = "numeric",
      desc = paste(
        "Ecozone IDs extracted from input 'ecoRaster' for each pixel group.",
        "Required input to CBM_vol2biomass")),
    createsOutput(
      objectName = "spatialUnits", objectClass = "numeric",
      desc = paste(
        "Spatial unit IDs extracted from input 'spuRaster' for each pixel group.",
        "Required input to CBM_vol2biomass")),
    createsOutput(
      objectName = "realAges", objectClass = "numeric",
      desc = paste(
        "Stand ages extracted from input 'ageRaster' for each pixel group.",
        "Required input to CBM_core.")),
    createsOutput(
      objectName = "disturbanceRasters", objectClass = "character",
      desc = paste(
        "List of disturbance rasters named by the disturbance year.",
        "This is either downloaded from the default URL or a user provided URL.",
        "Required input to CBM_core.")),
    createsOutput(
      objectName = "mySpuDmids", objectClass = "data.frame",
      desc = paste(
        "Table summarizing CBM-CFS3 disturbances possible within the spatial units.",
        "This links CBM-CFS3 disturbances with the values in the disturbance rasters.",
        "Required input to CBM_core."),
      columns = c(
        rasterID              = "Raster ID from 'userDist'",
        wholeStand            = "wholeStand flag from 'userDist'",
        spatial_unit_id       = "Spatial unit ID",
        disturbance_type_id   = "Disturbance type ID",
        disturbance_matrix_id = "Disturbance matrix ID",
        name                  = "Disturbance name",
        description           = "Disturbance description"
      )),
    createsOutput(
      objectName = "historicDMtype", objectClass = "numeric",
      desc = paste(
        "Historical disturbance type for each pixel group.",
        "Examples: 1 = wildfire; 2 = clearcut.",
        "Required input to CBM_core.")),
    createsOutput(
      objectName = "lastPassDMtype", objectClass = "numeric",
      desc = paste(
        "Last pass disturbance type for each pixel group.",
        "Examples: 1 = wildfire; 2 = clearcut.",
        "Required input to CBM_core."))
  )
))


### SCHEDULE EVENTS ----

doEvent.CBM_dataPrep_RIA <- function(sim, eventTime, eventType, debug = FALSE){
  switch(
    eventType,
    init = {
      sim <- Init(sim)
    },
    warning(noEventWarning(sim))
  )
  return(invisible(sim))
}


### EVENT FUNCTION: INIT ----

Init <- function(sim) {

  ## Create sim$allPixDT ----

  # Set which pixel group columns are assigned from which spatial inputs
  pgCols <- c(
    ages            = "ageRaster",
    gcids           = "gcIndexRaster",
    ecozones        = "ecoLocator",
    spatial_unit_id = "spuLocator"
  )

  # Read spatial inputs
  inRast <- list()
  for (rName in c("masterRaster", pgCols)){
    inRast[[rName]] <- sim[[rName]]
    if (is.null(inRast[[rName]])) stop(shQuote(rName), " input not found")
  }

  ## Convert masterRaster to SpatRaster
  for (rName in "masterRaster"){
    if (!inherits(inRast[[rName]], "SpatRaster")){
      inRast[[rName]] <- tryCatch(
        terra::rast(inRast[[rName]]),
        error = function(e) stop(
          shQuote(rName), " could not be converted to SpatRaster: ", e$message,
          call. = FALSE))
    }
  }

  ## Convert spatial inputs to SpatRaster and align with masterRaster
  for (rName in pgCols){

    if (inherits(inRast[[rName]], "sf")){

      rasCrop <- postProcess(
        inRast[[rName]],
        cropTo    = inRast$masterRaster,
        projectTo = inRast$masterRaster
      ) |> Cache()

      inRast[[rName]] <- terra::rasterize(
        terra::vect(rasCrop),
        inRast$masterRaster,
        fun   = "min", ## TODO: best method?
        field = names(inRast[[rName]])[[1]]
      ) |> Cache()

      rm(rasCrop)

    }else{

      inRast[[rName]] <- postProcess(
        inRast[[rName]],
        to     = inRast$masterRaster,
        method = P(sim)$resampling
      ) |> Cache()
    }
  }

  # Create sim$allPixDT: Summarize input values into table
  sim$allPixDT <- data.table::data.table(
    pixelIndex = 1:terra::ncell(inRast$masterRaster)
  )
  for (i in 1:length(pgCols)){
    sim$allPixDT[[names(pgCols)[[i]]]] <- terra::values(inRast[[pgCols[[i]]]])[,1]
  }
  setkeyv(sim$allPixDT, "pixelIndex")


  ## Create sim$spatialDT ----

  # Create sim$spatialDT: Summarize input raster values where masterRaster is not NA
  spatialDT <- sim$allPixDT[!is.na(terra::values(inRast$masterRaster)[,1]),]

  spatialDT_isNA <- is.na(spatialDT)
  if (any(spatialDT_isNA)){
    for (i in 1:length(pgCols)){
      if (any(spatialDT_isNA[, names(pgCols)[[i]]])) warning(
        "Pixels have been excluded from the simulation where there are no values in ",
        shQuote(pgCols[[i]]))
    }
    spatialDT <- spatialDT[!apply(spatialDT_isNA, 1, any),]
  }

  # Create pixel groups: groups of pixels with the same attributes
  spatialDT$pixelGroup <- LandR::generatePixelGroups(
    spatialDT, maxPixelGroup = 0, columns = names(pgCols)
  )

  # Keep only essential columns
  sim$spatialDT <- spatialDT[, c("pixelIndex", "pixelGroup", names(pgCols)), with = FALSE]


  ## Create sim$level3DT, sim$realAges, and sim$curveID ----

  level3DT <- unique(sim$spatialDT[, -("pixelIndex")])
  setkeyv(level3DT, "pixelGroup")

  # Create sim$curveID
  sim$curveID <- c("gcids") #, "ecozones" # "id_ecozone"
  ##TODO add to metadata -- use in multiple modules

  # Set sim$level3DT$gcids to be a factor
  set(level3DT, j = "gcids",
      value = factor(CBMutils::gcidsCreate(level3DT[, sim$curveID, with = FALSE])))

  # Create 'realAges' output object and set ages to be >= 2
  ## Temporary fix to CBM_core issue: https://github.com/PredictiveEcology/CBM_core/issues/1
  sim$realAges <- level3DT[, ages]
  level3DT[ages <= 2, ages := 2]
  setorderv(level3DT, "pixelGroup")

  # Join with spinup parameters
  setkeyv(level3DT, "spatial_unit_id")
  spinupParameters <- as.data.table(sim$spinupSQL[, c(1, 7)])

  setkeyv(spinupParameters,"id")
  spinupParameters <- setNames(spinupParameters, replace(names(spinupParameters), names(spinupParameters) == 'id', 'spatial_unit_id'))
  retInt <- merge.data.table(level3DT, spinupParameters,
                             by = "spatial_unit_id", all.x = TRUE)
  setkeyv(retInt, "pixelGroup")
  setkeyv(level3DT, "pixelGroup")
  sim$level3DT <- retInt


  ## Create sim$ecozones and sim$spatialUnits ----

  # create sim$ecozones and sim$spatialUnits to subset vol2biomass growth curves
  sim$ecozones <- sim$level3DT$ecozones
  sim$spatialUnits <- sim$level3DT$spatial_unit_id


  ## Create sim$speciesPixelGroup ----

  ## TODO:
  ## - Simplify this process to not require 2 extra input tables
  ## - Make this more generic to user input (this works only with the defaults)

  gcMeta <- sim$gcMeta
  if (!inherits(gcMeta, "data.table")){
    gcMeta <- tryCatch(
      data.table::as.data.table(gcMeta),
      error = function(e) stop(
        "'gcMeta' could not be converted to data.table: ", e$message, call. = FALSE))
  }

  # Get species_id
  gcMeta <- gcMeta |>
    merge(data.table::as.data.table(sim$canfi_species)[
      , .(canfi_species, name)], by = "canfi_species", all.x = TRUE) |>
    merge(data.table::as.data.table(sim$species_tr)[
      , .(species_id, name)], by = "name", all.x = TRUE)

  sim$speciesPixelGroup <- merge(
    unique(sim$spatialDT[, .(pixelGroup, gcids)]),
    gcMeta, all.x = TRUE)
  setkey(sim$speciesPixelGroup, "pixelGroup")

  unknownSpecies <- unique(subset(sim$speciesPixelGroup, is.na(species_id))$name)
  if (length(unknownSpecies) > 0) warning(
    "species_id could not be determined for specie(s): ",
    paste(shQuote(unknownSpecies), collapse = ", "))


  ## Create sim$mySpuDmids, sim$historicDMtype, and sim$lastPassDMtype ----

  # List disturbances possible within in each spatial unit
  spuIDs <- sort(unique(sim$level3DT$spatial_unit_id))
  listDist <- CBMutils::spuDist(
    spuIDs = spuIDs,
    dbPath = sim$dbPath,
    disturbance_matrix_association = sim$dMatrixAssociation
  )

  # Check if userDist already has all the required IDs
  if (all(c("spatial_unit_id", "disturbance_type_id", "disturbance_matrix_id") %in% names(sim$userDist))){
    sim$mySpuDmids <- sim$userDist
  }

  if (!suppliedElsewhere("mySpuDmids", sim)){

    # Read user disturbances
    userDist <- sim$userDist

    if (!inherits(userDist, "data.table")){
      userDist <- tryCatch(
        data.table::as.data.table(userDist),
        error = function(e) stop(
          "'userDist' could not be converted to data.table: ", e$message, call. = FALSE))
    }

    # Match user disturbances with CBM-CFS3 disturbance matrices
    userDistSpu <- userDist
    if (!"spatial_unit_id" %in% names(userDist)){
      userDistSpu <- do.call(rbind, lapply(spuIDs, function(spuID){
        cbind(spatial_unit_id = spuID, userDist)
      }))
    }else{
      distCols <- intersect(names(userDist), c("distName", "name", "rasterID", "wholeStand"))
      userDistSpu <- do.call(rbind, lapply(spuIDs, function(spuID){
        cbind(spatial_unit_id = spuID, unique(userDist[, distCols, with = FALSE]))
      }))
      userDistSpu <- merge(userDistSpu, userDist, by = c(distCols, "spatial_unit_id"), all.x = TRUE)
    }

    askUser <- interactive() & !identical(Sys.getenv("TESTTHAT"), "true")
    if (askUser) message(
      "Prompting user to match input disturbances with CBM-CFS3 disturbances:")

    sim$mySpuDmids <- do.call(rbind, lapply(1:nrow(userDistSpu), function(i){

      if ("disturbance_type_id" %in% names(userDistSpu)){
        userDistMatch <- subset(
          listDist, spatial_unit_id == userDistSpu[i,]$spatial_unit_id &
            disturbance_type_id == userDistSpu[i,]$disturbance_type_id)

      }else{

        userDistMatch <- CBMutils::spuDistMatch(
          userDistSpu[i,], listDist = listDist,
          ask = askUser
        ) |> Cache()
      }

      cbind(
        userDistSpu[i, setdiff(names(userDist), names(userDistMatch)), with = FALSE],
        userDistMatch)
    }))
  }

  # Set sim$historicDMtype to be wildfire
  sim$historicDMtype <- data.table::merge.data.table(
    sim$level3DT,
    unique(subset(listDist[, .(spatial_unit_id, disturbance_type_id, name)], tolower(name) == "wildfire")),
    by = "spatial_unit_id"
  )$disturbance_type_id

  # Set sim$lastPassDMtype to be wildfire
  ## TODO: this is where it could be something else then fire
  sim$lastPassDMtype <- sim$historicDMtype


  ## Return simList ----

  return(invisible(sim))
}


### INPUT OBJECTS ----

.inputObjects <- function(sim) {

  ## Data table inputs ----

  # 1. Growth and yield
  ## TODO add a data manipulation to adjust if the m3 are not given on a yearly basis.
  if (!suppliedElsewhere("userGcM3", sim)){

    if (suppliedElsewhere("userGcM3URL", sim) &
        !identical(sim$userGcM3URL, extractURL("userGcM3"))){

      sim$userGcM3 <- prepInputs(
        destinationPath = inputPath(sim),
        url = sim$userGcM3URL,
        fun = data.table::fread
      )

    }else{

      if (!suppliedElsewhere("userGcM3URL", sim, where = "user")) message(
        "User has not supplied growth curves ('userGcM3' or 'userGcM3URL'). ",
        "Default for RIA will be used.")

      sim$userGcM3 <- prepInputs(
        destinationPath = inputPath(sim),
        url        = extractURL("userGcM3"),
        targetFile = "curve_points_table.csv",
        fun        = data.table::fread
      )[, V1 := NULL]

      names(sim$userGcM3) <- c("gcids", "Age", "MerchVolume")
    }
  }

  # 2. Meta info about growth and yield curves
  if (!suppliedElsewhere("gcMeta", sim)) {

    if (suppliedElsewhere("gcMetaURL", sim) &
        !identical(sim$gcMetaURL, extractURL("gcMeta"))){

      sim$gcMeta <- prepInputs(
        destinationPath = inputPath(sim),
        url = sim$gcMetaURL,
        fun = data.table::fread
      )

    }else{

      if (!suppliedElsewhere("gcMetaURL", sim, where = "user")) message(
        "User has not supplied growth curve metadata ('gcMeta' or 'gcMetaURL'). ",
        "Default for RIA will be used.")

      sim$gcMeta <- prepInputs(
        destinationPath = inputPath(sim),
        url        = extractURL("gcMeta"),
        targetFile = "au_table.csv",
        fun        = data.table::fread
      )[, V1 := NULL]

      sim$gcMeta <- cbind(sim$gcMeta[, .(gcids = au_id)], sim$gcMeta)
    }
  }

  # 3. Disturbance information
  if (!suppliedElsewhere("userDist", sim) & !suppliedElsewhere("mySpuDmids", sim)  &
      suppliedElsewhere("userDistURL", sim)){

    sim$userDist <- prepInputs(
      destinationPath = inputPath(sim),
      url = sim$userDistURL,
      fun = data.table::fread
    )
  }

  # 4. Canfi species
  if (!suppliedElsewhere("canfi_species", sim)) {
    if (suppliedElsewhere("canfi_speciesURL", sim)){

      sim$canfi_species <- prepInputs(
        destinationPath = inputPath(sim),
        url        = sim$canfi_speciesURL,
        targetFile = "canfi_species.csv",
        fun        = fread)

    }else{
      sim$canfi_species <- prepInputs(
        destinationPath = inputPath(sim),
        url        = extractURL("canfi_species"),
        targetFile = "canfi_species.csv",
        fun        = fread)
    }
  }


  ## Spatial inputs ----

  # Master raster
  if (!suppliedElsewhere("masterRaster", sim)){

    if (suppliedElsewhere("masterRasterURL", sim) &
        !identical(sim$masterRasterURL, extractURL("masterRaster"))){

      sim$masterRaster <- prepInputs(
        destinationPath = inputPath(sim),
        url = sim$masterRasterURL
      )

    }else{

      if (!suppliedElsewhere("masterRasterURL", sim, where = "user")) message(
        "User has not supplied a master raster ('masterRaster' or 'masterRasterURL'). ",
        "Default for RIA will be used.")

      sim$masterRaster <- prepInputs(
        destinationPath = inputPath(sim),
        url        = extractURL("masterRaster"),
        targetFile = "RIA_rtm.tif",
        fun        = terra::rast
      )
    }
  }

  # Stand ages
  if (!suppliedElsewhere("ageRaster", sim)){

    if (suppliedElsewhere("ageRasterURL", sim) &
        !identical(sim$ageRasterURL, extractURL("ageRaster"))){

      sim$ageRaster <- prepInputs(
        destinationPath = inputPath(sim),
        url = sim$ageRasterURL
      )

    }else{

      if (!suppliedElsewhere("ageRasterURL", sim, where = "user")) message(
        "User has not supplied an age raster ('ageRaster' or 'ageRasterURL'). ",
        "Default for RIA will be used.")

      if (start(sim) != 2015) warning("Default `ageRaster` for RIA represents stand ages at year 2015", call. = FALSE)

      VRI2015 <- prepInputs(
        destinationPath = inputPath(sim),
        url         = extractURL("ageRaster"),
        targetFile  = "VEG_COMP_LYR_L1_POLY_2015.gdb.zip",
        archive     = NA,
        fun         = NA
      )

      sim$ageRaster <- sf::st_read(
        VRI2015,
        query = "SELECT CAST(PROJ_AGE_1 AS smallint) AS age FROM VEG_COMP_LYR_L1_POLY WHERE PROJ_AGE_1 IS NOT NULL",
        agr   = "constant",
        wkt_filter = if (any(sapply(c("masterRaster", "masterRasterURL"), suppliedElsewhere, sim, where = "user"))){
          sf::st_as_text(
            sf::st_transform(
              sf::st_buffer(
                sf::st_as_sfc(sf::st_bbox(sim$masterRaster)),
                max(terra::res(sim$masterRaster)),
                joinStyle = "MITRE", mitreLimit = 5
              ),
              crs = sf::st_crs(
                sf::st_read(VRI2015, query = "SELECT FID FROM VEG_COMP_LYR_L1_POLY LIMIT 1", quiet = TRUE)
              )))
          }else character(0),
        quiet = TRUE
      ) |> Cache()
    }
  }

  # Growth curves
  if (!suppliedElsewhere("gcIndexRaster", sim)){

    if (suppliedElsewhere("gcIndexRasterURL", sim) &
        !identical(sim$gcIndexRasterURL, extractURL("gcIndexRaster"))){

      sim$gcIndexRaster <- prepInputs(
        destinationPath = inputPath(sim),
        url = sim$gcIndexRasterURL
      )

    }else{

      if (!suppliedElsewhere("gcIndexRasterURL", sim, where = "user")) message(
        "User has not supplied a growth curve raster ('gcIndexRaster' or 'gcIndexRasterURL'). ",
        "Default for RIA will be used.")

      VRI2020 <- prepInputs(
        destinationPath = inputPath(sim),
        url         = extractURL("gcIndexRaster"),
        filename1   = "VRI_3Cols.zip",
        targetFile  = "VRI_3Cols.shp",
        alsoExtract = "similar",
        fun         = NA
      )

      sim$gcIndexRaster <- sf::st_read(
        VRI2020,
        query = "SELECT CAST(curve2 AS integer) AS gcid FROM VRI_3Cols WHERE curve2 IS NOT NULL",
        agr   = "constant",
        wkt_filter = if (any(sapply(c("masterRaster", "masterRasterURL"), suppliedElsewhere, sim, where = "user"))){
          sf::st_as_text(
            sf::st_transform(
              sf::st_buffer(
                sf::st_as_sfc(sf::st_bbox(sim$masterRaster)),
                max(terra::res(sim$masterRaster)),
                joinStyle = "MITRE", mitreLimit = 5
              ),
              crs = sf::st_crs(
                sf::st_read(VRI2020, query = "SELECT FID FROM VRI_3Cols LIMIT 1", quiet = TRUE)
              )))
        }else character(0),
        quiet = TRUE
      ) |> Cache()
    }
  }

  # Disturbances
  if (!suppliedElsewhere("disturbanceRasters", sim)){

    if (suppliedElsewhere("disturbanceRastersURL", sim) &
        !identical(sim$disturbanceRastersURL, extractURL("disturbanceRasters"))){

      drPaths <- preProcess(
        destinationPath = inputPath(sim),
        url = sim$disturbanceRastersURL,
        fun = NA
      )$targetFilePath

      # If extracted archive: list all files in directory
      if (dirname(drPaths) != inputPath(sim)){
        drPaths <- list.files(dirname(drPaths), full.names = TRUE)
      }

      # List files by year
      drInfo <- data.frame(
        path = drPaths,
        name = tools::file_path_sans_ext(basename(drPaths)),
        ext  = tolower(tools::file_ext(drPaths))
      )
      drInfo$year_regexpr <- regexpr("[0-9]{4}", drInfo$name)
      drInfo$year <- sapply(1:nrow(drInfo), function(i){
        if (drInfo[i,]$year_regexpr != -1){
          paste(
            strsplit(drInfo[i,]$name, "")[[1]][0:3 + drInfo[i,]$year_regexpr],
            collapse = "")
        }else NA
      })

      if (all(is.na(drInfo$year))) stop(
        "Disturbance raster(s) from 'disturbanceRasterURL' must be named with 4-digit years")
      drInfo <- drInfo[!is.na(drInfo$year),, drop = FALSE]

      # Choose file type to return for each year
      drYears <- unique(sort(drInfo$year))
      sim$disturbanceRasters <- sapply(setNames(drYears, drYears), function(drYear){
        drInfoYear <- subset(drInfo, year == drYear)
        if (nrow(drInfoYear) > 1){
          if ("grd" %in% drInfoYear$ext) return(subset(drInfoYear, ext == "grd")$path)
          if ("tif" %in% drInfoYear$ext) return(subset(drInfoYear, ext == "grd")$path)
          drInfoYear$size <- file.size(drInfoYear$path)
          drInfoYear$path[drInfoYear$size == max(drInfoYear$size)][[1]]
        }else drInfoYear$path
      })

    }else{

      if (!suppliedElsewhere("disturbanceRastersURL", sim, where = "user")) message(
        "User has not supplied disturbance rasters ('disturbanceRasters' or 'disturbanceRastersURL'). ",
        "Default for RIA will be used.")

      if (is.null(sim$masterRaster)) stop("'masterRaster' input not found")

      # Read disturbances
      dists <- list(
        fire = prepInputs(
          destinationPath = inputPath(sim),
          url         = extractURL("disturbanceRasters")[[1]],
          filename1   = "historicalFire_1985-2015.zip",
          targetFile  = "historicalFire_1985-2015.tif",
          fun         = terra::rast
        ),
        harvest = prepInputs(
          destinationPath = inputPath(sim),
          url         = extractURL("disturbanceRasters")[[2]],
          filename1   = "historicalHarvest_1985-2015.zip",
          targetFile  = "historicalHarvest_1985-2015.tif",
          fun         = terra::rast
        )
      )
      dists <- lapply(dists, setNames, 1985:2015)

      # Create disturbances table
      sim$disturbanceRasters <- data.table::data.table(
        pixelIndex = 1:terra::ncell(sim$masterRaster)
      )

      for (simYear in intersect(1985:2015, start(sim):end(sim))){

        distHarv <- terra::classify(dists$harvest[[as.character(simYear)]], cbind(1, 2L))
        distYear <- postProcess(
          terra::cover(
            dists$fire[[as.character(simYear)]],
            distHarv
          ) |> Cache(),
          to     = sim$masterRaster,
          method = "mode" ## TODO: best method?
        ) |> Cache()

        sim$disturbanceRasters[[as.character(simYear)]] <- terra::values(distYear)[,1]
      }

      # Disturbance information
      if (!suppliedElsewhere("userDist", sim) & !suppliedElsewhere("userDistURL", sim) &
          !suppliedElsewhere("mySpuDmids", sim)){

        mySpuDmidsCSV <- prepInputs(
          destinationPath = inputPath(sim),
          url        = extractURL("userDist"),
          targetFile = "mySpuDmids.csv",
          fun        = data.table::fread
        )

        # Strip matrix IDs
        sim$userDist <- mySpuDmidsCSV[, .(rasterID, wholeStand, spatial_unit_id)]
        sim$userDist$disturbance_type_id <- sapply(mySpuDmidsCSV$rasterID, switch, `1` = 1, `2` = 204)
        # sim$userDist$distDesc <- mySpuDmidsCSV$distName
        # sim$userDist$disturbance_type_id   <- sapply(mySpuDmidsCSV$rasterID, switch, `1` = 1, `2` = 4)
        # sim$userDist$disturbance_matrix_id <- mySpuDmidsCSV$disturbance_matrix_id
      }
    }
  }


  ## Return simList ----

  return(invisible(sim))

}


