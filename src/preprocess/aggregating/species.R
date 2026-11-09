
# https://www.ncbi.nlm.nih.gov/Taxonomy/Browser/wwwtax.cgi?id=13203
# https://www.ncbi.nlm.nih.gov/Taxonomy/Browser/wwwtax.cgi?id=59270
  #genus_subgenus_species

# 01 - import libraries =============================================================
library(lubridate)
library(dotenv)
load_dot_env(".env")
setwd(Sys.getenv("WORKING_DIR"))
source("src/base.R")
source("src/utils.R")
# 02 - global variables =========================================================

#define a dictionary of all valid species with corresponding codes
factor_codes <- c(
  phlebotomus_phlebotomus_papatasi = 0L, ##
  phlebotomus_paraphlebotomus_sergenti = 1L, ##
  sergentomyia_unknown_minuta = 2L,
  phlebotomus_larroussius_perniciosus = 3L, ##
  phlebotomus_larroussius_major = 4L, ##
  phlebotomus_larroussius_perfiliewi = 5L, ##
  phlebotomus_larroussius_tobbi = 6L, ##
  phlebotomus_transphlebotomus_mascittii = 7L, ##
  phlebotomus_paraphlebotomus_alexandri = 8L, ##
  sergentomyia_unknown_dentata = 9L,
  larroussius_larroussius_unknown = 10L,
  phlebotomus_adlerius_simici = 11L, ##
  phlebotomus_adlerius_balcanicus = 12L,  ##
  phlebotomus_larroussius_ariasi = 13L,
  phlebotomus_paraphlebotomus_similis = 14L, ##
  sergentomyia_unknown_palestiniensis = 15L,
  phlebotomus_larroussius_wenyoni = 16L,
  phlebotomus_larroussius_kandelakii = 17L, ##
  phlebotomus_adlerius_halepensis = 18L, ##,
  phlebotomus_adlerius_brevis = 19L,
  sergentomyia_unknown_antennata = 20L
)

# 03 - read data =========================================================
#define a function to get data and correct the species names
species_uniforming <- function (data, coding = FALSE) {
  #if spec on the data was 'Phlebotomus (Larroussius) galilaeus', it should be replaces with 'phlebotomus_larroussius_galilaeus'
  data <- data %>% mutate(spec = ifelse(tolower(spec) == tolower('Phlebotomus (Larroussius) galilaeus'), 'phlebotomus_larroussius_perfiliewi', spec))
  data <- data %>% mutate(spec = ifelse(tolower(spec) == tolower('phlebotomous_perfiliewi_galilaeus'), 'phlebotomus_larroussius_perfiliewi', spec))
  data <- data %>% mutate(spec = ifelse(tolower(spec) == tolower('phlebotomus_perfiliewi_galilaeus'), 'phlebotomus_larroussius_perfiliewi', spec))

  data <- data %>% mutate(spec = ifelse(tolower(spec) == tolower('phlebotomus_galilaeous'), 'phlebotomus_larroussius_perfiliewi', spec))
  data <- data %>% mutate(spec = ifelse(tolower(spec) == tolower('Phlebotomus (Larroussius) perfiliewi'), 'phlebotomus_larroussius_perfiliewi', spec))
  data <- data %>% mutate(spec = ifelse(tolower(spec) == tolower('Ph. perfiliewi transcaucasicus'), 'phlebotomus_larroussius_perfiliewi', spec))
  data <- data %>% mutate(spec = ifelse(tolower(spec) == tolower('Ph. perfiliewi transcaucasious'), 'phlebotomus_larroussius_perfiliewi', spec))
  data <- data %>% mutate(spec = ifelse(tolower(spec) == tolower('phlebotomus_perfiliewi'), 'phlebotomus_larroussius_perfiliewi', spec))
  data <- data %>% mutate(spec = ifelse(tolower(spec) == tolower('P.p.transcaucasius'), 'phlebotomus_larroussius_perfiliewi', spec))
  data <- data %>% mutate(spec = ifelse(tolower(spec) == tolower('P. p. trancaucasicus'), 'phlebotomus_larroussius_perfiliewi', spec))
  data <- data %>% mutate(spec = ifelse(tolower(spec) == tolower('P. p. transcaucasicus'), 'phlebotomus_larroussius_perfiliewi', spec))
  data <- data %>% mutate(spec = ifelse(tolower(spec) == tolower('Phlebotomus perfiliewi'), 'phlebotomus_larroussius_perfiliewi', spec))
  data <- data %>% mutate(spec = ifelse(tolower(spec) == tolower('phlebotomous_perfiliewi'), 'phlebotomus_larroussius_perfiliewi', spec))

  data <- data %>% mutate(spec = ifelse(tolower(spec) == tolower('Phlebotomus (Larroussius) tobbi'), 'phlebotomus_larroussius_tobbi', spec))
  data <- data %>% mutate(spec = ifelse(tolower(spec) == tolower('phlebotomous_tobbi'), 'phlebotomus_larroussius_tobbi', spec))
  data <- data %>% mutate(spec = ifelse(tolower(spec) == tolower('Ph. tobbi'), 'phlebotomus_larroussius_tobbi', spec))
  data <- data %>% mutate(spec = ifelse(tolower(spec) == tolower('Phlebotomus tobbi'), 'phlebotomus_larroussius_tobbi', spec))
  data <- data %>% mutate(spec = ifelse(tolower(spec) == tolower('P. tobbi'), 'phlebotomus_larroussius_tobbi', spec))
  data <- data %>% mutate(spec = ifelse(tolower(spec) == tolower(' P. tobbi'), 'phlebotomus_larroussius_tobbi', spec))
  data <- data %>% mutate(spec = ifelse(tolower(spec) == tolower('P.tobbi'), 'phlebotomus_larroussius_tobbi', spec))
  data <- data %>% mutate(spec = ifelse(tolower(spec) == tolower('P. Tobbi'), 'phlebotomus_larroussius_tobbi', spec))
  data <- data %>% mutate(spec = ifelse(tolower(spec) == tolower('P.tobbi'), 'phlebotomus_larroussius_tobbi', spec))
  data <- data %>% mutate(spec = ifelse(tolower(spec) == tolower('phlebotomus_tobbi'), 'phlebotomus_larroussius_tobbi', spec))

  data <- data %>% mutate(spec = ifelse(tolower(spec) == tolower('Phlebotomus (Larroussius) major'), 'phlebotomus_larroussius_major', spec))
  data <- data %>% mutate(spec = ifelse(tolower(spec) == tolower('P. major s.l.'), 'phlebotomus_larroussius_major', spec))
  data <- data %>% mutate(spec = ifelse(tolower(spec) == tolower('P. major s.l'), 'phlebotomus_larroussius_major', spec))
  data <- data %>% mutate(spec = ifelse(tolower(spec) == tolower('P. major s.l..'), 'phlebotomus_larroussius_major', spec))
  data <- data %>% mutate(spec = ifelse(tolower(spec) == tolower('phlebotomus_major_sl'), 'phlebotomus_larroussius_major', spec))
  data <- data %>% mutate(spec = ifelse(tolower(spec) == tolower('Phlebotomus major s.l.'), 'phlebotomus_larroussius_major', spec))

  ## Neglectus, based on the Yoni comment, this subgenus should be converted to Major ========================

  data <- data %>% mutate(spec = ifelse(tolower(spec) == tolower('Phlebotomus (Larroussius) neglectus'), 'phlebotomus_larroussius_major', spec))
  data <- data %>% mutate(spec = ifelse(tolower(spec) == tolower('phlebotomous_neglectus'), 'phlebotomus_larroussius_major', spec))
  data <- data %>% mutate(spec = ifelse(tolower(spec) == tolower('Phlebotomus neglectus'), 'phlebotomus_larroussius_major', spec))
  data <- data %>% mutate(spec = ifelse(tolower(spec) == tolower('phlebotomus_cf_neglectus'), 'phlebotomus_larroussius_major', spec))
  data <- data %>% mutate(spec = ifelse(tolower(spec) == tolower('phlebotomus_neglectus'), 'phlebotomus_larroussius_major', spec))
  data <- data %>% mutate(spec = ifelse(tolower(spec) == tolower('phlebotomous_syriacus'), 'phlebotomus_larroussius_major', spec))
  data <- data %>% mutate(spec = ifelse(tolower(spec) == tolower('phlebotomus_syriacus'), 'phlebotomus_larroussius_major', spec))
  data <- data %>% mutate(spec = ifelse(tolower(spec) == tolower('Phlebotomus syriacus'), 'phlebotomus_larroussius_major', spec))


  data <- data %>% mutate(spec = ifelse(tolower(spec) == tolower('Phlebotomus (Larroussius) longicuspis'), 'phlebotomus_larroussius_longicuspis', spec))
  data <- data %>% mutate(spec = ifelse(tolower(spec) == tolower('longicuspis'), 'phlebotomus_larroussius_longicuspis', spec))

  data <- data %>% mutate(spec = ifelse(tolower(spec) == tolower('phlebotomus_kandelakii'), 'phlebotomus_larroussius_kandelakii', spec))
  data <- data %>% mutate(spec = ifelse(tolower(spec) == tolower('Phlebotomus kandelakii'), 'phlebotomus_larroussius_kandelakii', spec))

  data <- data %>% mutate(spec = ifelse(tolower(spec) == tolower('phlebotomus_wenyoini'), 'phlebotomus_larroussius_wenyoni', spec))

  data <- data %>% mutate(spec = ifelse(tolower(spec) == tolower('Phlebotomus (Larroussius) sp'), 'larroussius_larroussius_unknown', spec))
  data <- data %>% mutate(spec = ifelse(tolower(spec) == tolower('larroussius_sp'), 'larroussius_larroussius_unknown', spec))
  data <- data %>% mutate(spec = ifelse(tolower(spec) == tolower('Larroussiuss sp.'), 'larroussius_larroussius_unknown', spec))
  data <- data %>% mutate(spec = ifelse(tolower(spec) == tolower('phlebotomus_larroussius_Unidentified'), 'larroussius_larroussius_unknown', spec))
  data <- data %>% mutate(spec = ifelse(tolower(spec) == tolower('Larroussius sp'), 'larroussius_larroussius_unknown', spec)) #****
  data <- data %>% mutate(spec = ifelse(tolower(spec) == tolower('Larroussius sp.'), 'larroussius_larroussius_unknown', spec))
  data <- data %>% mutate(spec = ifelse(tolower(spec) == tolower('larroussius'), 'larroussius_larroussius_unknown', spec))


  data <- data %>% mutate(spec = ifelse(tolower(spec) == tolower('phlebotomus_larroussius_perniciosus'), 'phlebotomus_larroussius_perniciosus', spec))
  data <- data %>% mutate(spec = ifelse(tolower(spec) == tolower('phlebotomus _larroussius_perniciosus'), 'phlebotomus_larroussius_perniciosus', spec))
  data <- data %>% mutate(spec = ifelse(tolower(spec) == tolower('P. perniciosus'), 'phlebotomus_larroussius_perniciosus', spec))
  data <- data %>% mutate(spec = ifelse(tolower(spec) == tolower('phlebotomous_perniciosus'), 'phlebotomus_larroussius_perniciosus', spec))
  data <- data %>% mutate(spec = ifelse(tolower(spec) == tolower('phlebotomus_perniciosus'), 'phlebotomus_larroussius_perniciosus', spec))
  data <- data %>% mutate(spec = ifelse(tolower(spec) == tolower('Ph. (L.) perniciosus'), 'phlebotomus_larroussius_perniciosus', spec))
  data <- data %>% mutate(spec = ifelse(tolower(spec) == tolower('perniciosus'), 'phlebotomus_larroussius_perniciosus', spec))
  data <- data %>% mutate(spec = ifelse(tolower(spec) == tolower('Phlebotomus perniciosus'), 'phlebotomus_larroussius_perniciosus', spec))


  data <- data %>% mutate(spec = ifelse(tolower(spec) == tolower('phlebotomus_larroussius_ariasi'), 'phlebotomus_larroussius_ariasi', spec))
  data <- data %>% mutate(spec = ifelse(tolower(spec) == tolower('ariasi'), 'phlebotomus_larroussius_ariasi', spec))
  data <- data %>% mutate(spec = ifelse(tolower(spec) == tolower('Phlebotomus ariasi'), 'phlebotomus_larroussius_ariasi', spec))
  data <- data %>% mutate(spec = ifelse(tolower(spec) == tolower('Ph. (L.) ariasi'), 'phlebotomus_larroussius_ariasi', spec))
  data <- data %>% mutate(spec = ifelse(tolower(spec) == tolower('phlebotomus_ariasi'), 'phlebotomus_larroussius_ariasi', spec))

  data <- data %>% mutate(spec = ifelse(tolower(spec) == tolower('Phlebotomus (Paraphlebotomus) similis'), 'phlebotomus_paraphlebotomus_similis', spec))
  data <- data %>% mutate(spec = ifelse(tolower(spec) == tolower('Phlebotomus similis'), 'phlebotomus_paraphlebotomus_similis', spec))
  data <- data %>% mutate(spec = ifelse(tolower(spec) == tolower('phlebotomus_similis'), 'phlebotomus_paraphlebotomus_similis', spec))
  data <- data %>% mutate(spec = ifelse(tolower(spec) == tolower('phlebotomus_cf_similis'), 'phlebotomus_paraphlebotomus_similis', spec))


  data <- data %>% mutate(spec = ifelse(tolower(spec) == tolower('Phlebotomus (Paraphlebotomus) sergenti'), 'phlebotomus_paraphlebotomus_sergenti', spec))
  data <- data %>% mutate(spec = ifelse(tolower(spec) == tolower('sergenti'), 'phlebotomus_paraphlebotomus_sergenti', spec))
  data <- data %>% mutate(spec = ifelse(tolower(spec) == tolower('Ph.(P.) sergenti'), 'phlebotomus_paraphlebotomus_sergenti', spec))
  data <- data %>% mutate(spec = ifelse(tolower(spec) == tolower('phlebotomus_sergenti'), 'phlebotomus_paraphlebotomus_sergenti', spec))
  data <- data %>% mutate(spec = ifelse(tolower(spec) == tolower('P. sergenti'), 'phlebotomus_paraphlebotomus_sergenti', spec))
  data <- data %>% mutate(spec = ifelse(tolower(spec) == tolower('P.sergenti'), 'phlebotomus_paraphlebotomus_sergenti', spec))
  data <- data %>% mutate(spec = ifelse(tolower(spec) == tolower('Phlebotomus sergenti'), 'phlebotomus_paraphlebotomus_sergenti', spec))
  data <- data %>% mutate(spec = ifelse(tolower(spec) == tolower('sergentomyia_sergentomyia_sergenti'), 'phlebotomus_paraphlebotomus_sergenti', spec))
  data <- data %>% mutate(spec = ifelse(tolower(spec) == tolower('phlebotomus_sergenti_sl'), 'phlebotomus_paraphlebotomus_sergenti', spec))

  data <- data %>% mutate(spec = ifelse(tolower(spec) == tolower('sergenti/chabaudi'), 'phlebotomus_paraphlebotomus_chabaudi', spec))
  data <- data %>% mutate(spec = ifelse(tolower(spec) == tolower('chabaudi'), 'phlebotomus_paraphlebotomus_chabaudi', spec))
  data <- data %>% mutate(spec = ifelse(tolower(spec) == tolower('Phlebotomus chabaudi'), 'phlebotomus_paraphlebotomus_chabaudi', spec))


  data <- data %>% mutate(spec = ifelse(tolower(spec) == tolower('phlebotomus_jacusieli'), 'phlebotomus_paraphlebotomus_jacusieli', spec))

  data <- data %>% mutate(spec = ifelse(tolower(spec) == tolower('Phlebotomus (Paraphlebotomus) sp'), 'phlebotomus_paraphlebotomus_unknown', spec))
  data <- data %>% mutate(spec = ifelse(tolower(spec) == tolower('phlebotomus_paraphlebotomus_Unidentified'), 'phlebotomus_paraphlebotomus_unknown', spec))
  data <- data %>% mutate(spec = ifelse(tolower(spec) == tolower('paraphlebotomus_sp'), 'phlebotomus_paraphlebotomus_unknown', spec))
  data <- data %>% mutate(spec = ifelse(tolower(spec) == tolower('paraphlebotomus'), 'phlebotomus_paraphlebotomus_unknown', spec))


  data <- data %>% mutate(spec = ifelse(tolower(spec) == tolower('alexandri'), 'phlebotomus_paraphlebotomus_alexandri', spec))
  data <- data %>% mutate(spec = ifelse(tolower(spec) == tolower('P. alexandri'), 'phlebotomus_paraphlebotomus_alexandri', spec))
  data <- data %>% mutate(spec = ifelse(tolower(spec) == tolower('Phlebotomus alexandri'), 'phlebotomus_paraphlebotomus_alexandri', spec))
  data <- data %>% mutate(spec = ifelse(tolower(spec) == tolower('phlebotomus_alexandri'), 'phlebotomus_paraphlebotomus_alexandri', spec))

  data <- data %>% mutate(spec = ifelse(tolower(spec) == tolower('Phlebotomus (Phlebotomus) papatasi'), 'phlebotomus_phlebotomus_papatasi', spec))
  data <- data %>% mutate(spec = ifelse(tolower(spec) == tolower('Phlebotomus papatasi'), 'phlebotomus_phlebotomus_papatasi', spec))
  data <- data %>% mutate(spec = ifelse(tolower(spec) == tolower('P. papatasi'), 'phlebotomus_phlebotomus_papatasi', spec))
  data <- data %>% mutate(spec = ifelse(tolower(spec) == tolower('P.papatasi'), 'phlebotomus_phlebotomus_papatasi', spec))
  data <- data %>% mutate(spec = ifelse(tolower(spec) == tolower('papatasi'), 'phlebotomus_phlebotomus_papatasi', spec))
  data <- data %>% mutate(spec = ifelse(tolower(spec) == tolower('phlebotomous_papatasi'), 'phlebotomus_phlebotomus_papatasi', spec))
  data <- data %>% mutate(spec = ifelse(tolower(spec) == tolower('phlebotomus_papatasi'), 'phlebotomus_phlebotomus_papatasi', spec))

  data <- data %>% mutate(spec = ifelse(tolower(spec) == tolower('Phlebotomus (Phlebotomus) simici'), 'phlebotomus_adlerius_simici', spec))
  data <- data %>% mutate(spec = ifelse(tolower(spec) == tolower('Phlebotomus (Adlerius) simici'), 'phlebotomus_adlerius_simici', spec))
  data <- data %>% mutate(spec = ifelse(tolower(spec) == tolower('Phlebotomus simici'), 'phlebotomus_adlerius_simici', spec))
  data <- data %>% mutate(spec = ifelse(tolower(spec) == tolower('phlebotomus_simici'), 'phlebotomus_adlerius_simici', spec))


  data <- data %>% mutate(spec = ifelse(tolower(spec) == tolower('Phlebotomus (Adlerius) spp'), 'adlerius_adlerius_unknown', spec)) # Maybe we should change this to phlebotomus_adlerius_simic. because we have just one location for thid type.
  data <- data %>% mutate(spec = ifelse(tolower(spec) == tolower('adlerius'), 'adlerius_adlerius_unknown', spec))


  data <- data %>% mutate(spec = ifelse(tolower(spec) == tolower('Phlebotomus balcanicus'), 'phlebotomus_adlerius_balcanicus', spec))
  data <- data %>% mutate(spec = ifelse(tolower(spec) == tolower('phlebotomus_balcanicus'), 'phlebotomus_adlerius_balcanicus', spec))

  data <- data %>% mutate(spec = ifelse(tolower(spec) == tolower('Phlebotomus halepensis'), 'phlebotomus_adlerius_halepensis', spec))
  data <- data %>% mutate(spec = ifelse(tolower(spec) == tolower('phlebotomus_halepensis'), 'phlebotomus_adlerius_halepensis', spec))


  data <- data %>% mutate(spec = ifelse(tolower(spec) == tolower('phlebotomus_brevis'), 'phlebotomus_adlerius_brevis', spec))

  data <- data %>% mutate(spec = ifelse(tolower(spec) == tolower('phlebotomus_creticus'), 'phlebotomus_adlerius_creticus', spec))
  data <- data %>% mutate(spec = ifelse(tolower(spec) == tolower('Phlebotomus creticus'), 'phlebotomus_adlerius_creticus', spec))
  data <- data %>% mutate(spec = ifelse(tolower(spec) == tolower('Phlebotomus creticus'), 'phlebotomus_adlerius_creticus', spec))


  data <- data %>% mutate(spec = ifelse(tolower(spec) == tolower('Phlebotomus (Phlebotomus) spp'), 'phlebotomus_phlebotomus_unknown', spec))
  data <- data %>% mutate(spec = ifelse(tolower(spec) == tolower('phlebotomus_sp'), 'phlebotomus_phlebotomus_unknown', spec))
  data <- data %>% mutate(spec = ifelse(tolower(spec) == tolower('phlebotomous_unidentified'), 'phlebotomus_phlebotomus_unknown', spec))
  data <- data %>% mutate(spec = ifelse(tolower(spec) == tolower('phlebotomous'), 'phlebotomus_phlebotomus_unknown', spec))


  data <- data %>% mutate(spec = ifelse(tolower(spec) == tolower('Sergentomyia (Sergentomyia) dentata'), 'sergentomyia_unknown_dentata', spec))
  data <- data %>% mutate(spec = ifelse(tolower(spec) == tolower('S. dentata'), 'sergentomyia_unknown_dentata', spec))
  data <- data %>% mutate(spec = ifelse(tolower(spec) == tolower('S.dentata'), 'sergentomyia_unknown_dentata', spec))
  data <- data %>% mutate(spec = ifelse(tolower(spec) == tolower('sergenotmyia_dentata'), 'sergentomyia_unknown_dentata', spec))
  data <- data %>% mutate(spec = ifelse(tolower(spec) == tolower('Sergentomyia dentata'), 'sergentomyia_unknown_dentata', spec))
  data <- data %>% mutate(spec = ifelse(tolower(spec) == tolower('sergentomyia_dentata'), 'sergentomyia_unknown_dentata', spec))
  data <- data %>% mutate(spec = ifelse(tolower(spec) == tolower('s_dentata'), 'sergentomyia_unknown_dentata', spec))

  data <- data %>% mutate(spec = ifelse(tolower(spec) == tolower('Sergentomyia christophersi'), 'sergentomyia_unknown_christophersi', spec))

  data <- data %>% mutate(spec = ifelse(tolower(spec) == tolower('Sergentomyia antennata'), 'sergentomyia_unknown_antennata', spec))
  data <- data %>% mutate(spec = ifelse(tolower(spec) == tolower('s_antennata'), 'sergentomyia_unknown_antennata', spec))



  data <- data %>% mutate(spec = ifelse(tolower(spec) == tolower('Sergentomyia (Sergentomyia) minuta'), 'sergentomyia_unknown_minuta', spec))
  data <- data %>% mutate(spec = ifelse(tolower(spec) == tolower('sergentomyia_sergentomyia_minuta'), 'sergentomyia_unknown_minuta', spec))
  data <- data %>% mutate(spec = ifelse(tolower(spec) == tolower('minuta'), 'sergentomyia_unknown_minuta', spec))
  data <- data %>% mutate(spec = ifelse(tolower(spec) == tolower('S. minuta'), 'sergentomyia_unknown_minuta', spec))
  data <- data %>% mutate(spec = ifelse(tolower(spec) == tolower('Sergentomyia minuta'), 'sergentomyia_unknown_minuta', spec))
  data <- data %>% mutate(spec = ifelse(tolower(spec) == tolower('sergentomyia_minuta'), 'sergentomyia_unknown_minuta', spec))
  data <- data %>% mutate(spec = ifelse(tolower(spec) == tolower('phlebotomus_sergentomyia_minuta'), 'sergentomyia_unknown_minuta', spec))
  data <- data %>% mutate(spec = ifelse(tolower(spec) == tolower('phlebotomus_sergentomyia_minuta'), 'sergentomyia_unknown_minuta', spec))
  data <- data %>% mutate(spec = ifelse(tolower(spec) == tolower('phlebotomous_minuta'), 'sergentomyia_unknown_minuta', spec))
  data <- data %>% mutate(spec = ifelse(tolower(spec) == tolower('s_minuta'), 'sergentomyia_unknown_minuta', spec))


  data <- data %>% mutate(spec = ifelse(tolower(spec) == tolower('Sergentomyia (Sergentomyia) fallax'), 'sergentomyia_unknown_fallax', spec))
  data <- data %>% mutate(spec = ifelse(tolower(spec) == tolower('sergentomyia_fallax'), 'sergentomyia_unknown_fallax', spec))
  data <- data %>% mutate(spec = ifelse(tolower(spec) == tolower('Sergentomyia fallax'), 'sergentomyia_unknown_fallax', spec))

  data <- data %>% mutate(spec = ifelse(tolower(spec) == tolower('Sergentomyia (Sergentomyia) theodori'), 'sergentomyia_unknown_theodori', spec))
  data <- data %>% mutate(spec = ifelse(tolower(spec) == tolower('sergentomyia_theodori'), 'sergentomyia_unknown_theodori', spec))
  data <- data %>% mutate(spec = ifelse(tolower(spec) == tolower('sergentomyia_palestiniensis'), 'sergentomyia_unknown_palestiniensis', spec))

  data <- data %>% mutate(spec = ifelse(tolower(spec) == tolower('Sergentomyia (Sergentomyia) sp'), 'sergentomyia_unknown_unknown', spec))
  data <- data %>% mutate(spec = ifelse(tolower(spec) == tolower('sergentomyia_sp'), 'sergentomyia_unknown_unknown', spec))
  data <- data %>% mutate(spec = ifelse(tolower(spec) == tolower('sergentomyia_Unidentified_Unidentified'), 'sergentomyia_unknown_unknown', spec))
  data <- data %>% mutate(spec = ifelse(tolower(spec) == tolower('sergentomyia'), 'sergentomyia_unknown_unknown', spec))

  data <- data %>% mutate(spec = ifelse(tolower(spec) == tolower('Ph.(T.) mascittii'), 'phlebotomus_transphlebotomus_mascittii', spec))
  data <- data %>% mutate(spec = ifelse(tolower(spec) == tolower('Phlebotomus mascittii'), 'phlebotomus_transphlebotomus_mascittii', spec))
  data <- data %>% mutate(spec = ifelse(tolower(spec) == tolower('phlebotomous_mascittii'), 'phlebotomus_transphlebotomus_mascittii', spec))
  data <- data %>% mutate(spec = ifelse(tolower(spec) == tolower('phlebotomous_mascitti'), 'phlebotomus_transphlebotomus_mascittii', spec))
  data <- data %>% mutate(spec = ifelse(tolower(spec) == tolower('phlebotomus_mascitii'), 'phlebotomus_transphlebotomus_mascittii', spec))
  data <- data %>% mutate(spec = ifelse(tolower(spec) == tolower('phlebotomus_mascitti'), 'phlebotomus_transphlebotomus_mascittii', spec))
  data <- data %>% mutate(spec = ifelse(tolower(spec) == tolower('phlebotomus_mascittii'), 'phlebotomus_transphlebotomus_mascittii', spec))


  data <- data %>% mutate(spec = ifelse(tolower(spec) == tolower('phlebotomus_killicki'), 'phlebotomus_transphlebotomus_killicki', spec))
  data <- data %>% mutate(spec = ifelse(tolower(spec) == tolower('phlebotomus_anatolicus'), 'phlebotomus_transphlebotomus_anatolicus', spec))

  data <- data %>% mutate(spec = ifelse(tolower(spec) == tolower('transphlebotomus_sp'), 'transphlebotomus_transphlebotomus_unknown', spec))
  data <- data %>% mutate(spec = ifelse(tolower(spec) == tolower('transphlebotomus'), 'transphlebotomus_transphlebotomus_unknown', spec))

  data <- data %>% mutate(spec = ifelse(tolower(spec) == tolower('phleboto'), 'phlebotomus_unknown_unknown', spec))

  data <- data %>% mutate(spec = ifelse(tolower(spec) == tolower('Unidentified_Unidentified_Unidentified'), 'unknown_unknown_unknown', spec))
  data <- data %>% mutate(spec = ifelse(tolower(spec) == tolower('no_identified'), 'unknown_unknown_unknown', spec))
  data <- data %>% mutate(spec = ifelse(tolower(spec) == tolower('no'), 'unknown_unknown_unknown', spec))
  data <- data %>% mutate(spec = ifelse(tolower(spec) == tolower('Unknown'), 'unknown_unknown_unknown', spec))
  data <- data %>% mutate(spec = ifelse(tolower(spec) == tolower('Unknown_sp'), 'unknown_unknown_unknown', spec))
  data <- data %>% mutate(spec = ifelse(tolower(spec) == tolower('unidentified'), 'unknown_unknown_unknown', spec))


  data <- data %>% mutate(spec = ifelse(tolower(trimws(spec)) == '', 'unknown_unknown_unknown', spec))
  data <- data %>% mutate(spec = ifelse(tolower(trimws(spec)) == '?_?', 'unknown_unknown_unknown', spec))
  data <- data %>% mutate(spec = ifelse(is.na(spec), 'unknown_unknown_unknown', spec))

  if (coding) {
    #data <- data %>% mutate(spec_code = factor(spec, levels = spec_name, labels = spec_code))
    data$spec_code <- factor_codes[data$spec]
  }

  return(data)
}

data <- read_sandflies_data(name ="aggregated", type = "processed")

# 03 - save data ==================================================================
data <- species_uniforming(data, coding = TRUE)
# remove the records with no spec_code
data <- data %>% filter(!is.na(spec_code))
#xx <- data %>% filter(is.na(spec_code))
# 20 Remove duplicated rows =========================================================
# In some cases, the rows are duplicated in various datasets.
cname <- c("lat", "lon", "sdate", "edate", "spec", "spec_code")

duplicated_index <- duplicated(data[cname]) | duplicated(data[cname], fromLast = TRUE)
paste0("Number of duplicated records: ", sum(duplicated_index))

duplicated_data <- data[duplicated_index, ]

# If duplicated records belong to the same dataset, we assume that the collector used different trap IDs
# and that each record corresponds to a different trap. Therefore, we should keep all of them and then merge them.

duplicated_data <- duplicated_data %>% group_by(lat, lon, sdate, edate, spec, spec_code, ds) %>%
  summarise(nt = sum(nt), nsm = sum(nsm), nsf = sum (nsm), nsu = sum (nsu), nst = sum(nst)) %>% ungroup()

# if duplicated records belong to different datasets,
# we assumed that data duplicated and we should keep just one of them.
duplicated_data <- duplicated_data %>% distinct(across(all_of(cname)), .keep_all = TRUE)

# make the same order of columns
duplicated_data <- duplicated_data[, colnames(data)]


data <- data[-which(duplicated_index), ]
data <- rbind(data, duplicated_data)

# check again
duplicated_index <- duplicated(data[cname]) | duplicated(data[cname], fromLast = TRUE)
paste0("Number of duplicated records: ", sum(duplicated_index))

# 21 - save data ==================================================================
write_sandflies_data(data, name = "aggregated_species")

# plot bar char x-axis: species, y-axis: number of records
data %>% group_by(spec) %>% summarise(n = n()) %>% ggplot(aes(x = reorder(spec, n), y = n)) +
  geom_bar(stat = "identity") +
  theme(axis.text.x = element_text(angle = 90, hjust = 1)) +
  labs(x = "Species", y = "Number of records") +
  ggtitle("Number of records per species") +
  theme_minimal() +
  theme(axis.text.x = element_text(angle = 90, hjust = 1))