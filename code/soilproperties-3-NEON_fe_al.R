# Erin C Rooney
# SOMMOS data
# AO:DC ratios for manuscript

#load libraries-------------------------------
source("code/0-method-packages.R")


#load data-------------------------------------
sommos_csv = read.csv("processed/horizon_processed4.csv")
neon_barr_csv = read.csv("processed/neon_barr_biogeochem.csv")
neon_heal_csv = read.csv("processed/neon_heal_biogeochem.csv")
neon_tool_csv = read.csv("processed/neon_tool_biogeochem.csv")
neon_bona_csv = read.csv("processed/neon_bona_biogeochem.csv")



#process data------------------------------------
sommos_proc = sommos_csv %>% 
dplyr::select(site, horizon_type, midpoint_depth.cm, DC_Al.g100g, 
              DC_Fe.g100g, DC_Mn.g100g, DC_Si.g100g, SP_Al.g100g, SP_Fe.g100g, 
              SP_Mn.g100g, SP_Si.g100g, AO_Al.g100g, AO_Fe.g100g, AO_Mn.mgkg, AO_Si.g100g) %>% 
  # create columns for indices
  dplyr::mutate(AO = (AO_Fe.g100g+AO_Al.g100g),
                SP = (SP_Fe.g100g+SP_Al.g100g),
                DC = (DC_Fe.g100g+DC_Al.g100g),
                AO_DC = (DC/AO),
                SP_DC = (SP/DC))
                
neon_proc = 
  neon_tool_csv %>% 
  bind_rows(neon_heal_csv, neon_barr_csv, neon_bona_csv)


neon_proc = neon_proc %>% 
  dplyr::select(siteID, plotID, biogeoCenterDepth, alKcl, 
                feKcl, nitrogenTot, estimatedOC, carbonTot, ctonRatio, acidity, OlsenPExtractable, waterSatx, alOxalate, feOxalate, alCitDithionate, 
                feCitDithionate) %>% 
  # create columns for indices
  dplyr::mutate(AO = (alOxalate+feOxalate),
                KCL = (alKcl+feKcl),
                DC = (alCitDithionate+feCitDithionate)-(alOxalate+feOxalate),
                DC_AO = (DC/AO),
                KCL_DC = (KCL/DC))
  
neon_proc_DC = neon_proc %>% 
  filter(DC>0 & AO>0) 


neon_proc = neon_proc %>% 
  mutate(siteID = factor (siteID, levels = c("BARR", "TOOL", "BONA", "HEAL"))) 

neon_proc_DC = neon_proc_DC %>% 
  mutate(siteID = factor (siteID, levels = c("BARR", "TOOL", "BONA", "HEAL")))


# ggplot set up-----------------------------------
theme_er <- function() {  # this for all the elements common across plots
  theme_bw() %+replace%
    theme(legend.position = "none",
          legend.key=element_blank(),
          legend.title = element_blank(),
          legend.text = element_text(size = 12),
          legend.key.size = unit(1.5, 'lines'),
          panel.border = element_rect(color="black",size=2, fill = NA),
          plot.title = element_text(hjust = 0.5, size = 14),
          plot.subtitle = element_text(hjust = 0.5, size = 12, lineheight = 1.5),
          axis.text = element_text(size = 12, color = "black"),
          axis.title = element_text(size = 12, face = "bold", color = "black"),
          # formatting for facets
          panel.background = element_blank(),
          strip.background = element_rect(colour="white", fill="white"), #facet formatting
          panel.spacing.x = unit(1.5, "lines"), #facet spacing for x axis
          panel.spacing.y = unit(1.5, "lines"), #facet spacing for x axis
          strip.text.x = element_text(size=12, face="bold"), #facet labels
          strip.text.y = element_text(size=12, face="bold", angle = 270) #facet labels
    )
}

#
theme_erclean <- function () {
   theme_clean() %+replace%
    theme(legend.position = "none",
          legend.key = element_blank(),
          legend.title = element_blank(),
          legend.text = element_text(size = 12),
          legend.key.size = unit(1.5, 'lines'),
          plot.title = element_text(hjust = 0.5, size = 14),
          plot.subtitle = element_text(hjust = 0.5, size = 12, lineheight = 1.5),
          axis.text = element_text(size = 12, color = "black"),
          axis.text.x = element_text(angle = 90),
          axis.title = element_text(size = 12, face = "bold", color = "black"),
          strip.background = element_rect(colour="white", fill="white"), #facet formatting
          panel.spacing.x = unit(1.5, "lines"), #facet spacing for x axis
          panel.spacing.y = unit(1.5, "lines"), #facet spacing for x axis
          strip.text.x = element_text(size=12, face="bold"), #facet labels
          strip.text.y = element_text(size=12, face="bold", angle = 270) #facet labels
          )
 }
      
# select data-----------------------------------
# barrow = sommos_csv$site=="BARR"
# healy = sommos_csv$site=="HEAL"
# toolik = sommos_csv$site=="TOOL"
# bona = sommos_csv$site=="BONA"
# data = as.data.frame(barrow)
# data = as.data.frame(healy)
# data = as.data.frame(toolik)
# data = as.data.frame(bona)


#aov_hsd---------------------------------------

# sommos_aov1 = aov(data = sommos_proc, SP_DC ~ site)
# summary(sommos_aov1)
# 
# SPDC_hsd = HSD.test(sommos_aov1,"site")
# print(SPDC_hsd)
# print(SPDC_hsd$groups)
# 
# dcao_aov1 = aov(data = neon_proc_DC, DC_AO ~ siteID)
# summary(dcao_aov1)
# 
# dcao_hsd = HSD.test(dcao_aov1,"siteID")
# print(dcao_hsd)
# print(dcao_hsd$groups)
# 
# 
# 
# 
dcao_aov1 = aov(data = neon_proc_DC, DC_AO ~ siteID * biogeoCenterDepth)
summary(dcao_aov1)

dcao_hsd = HSD.test(dcao_aov1,"siteID")
print(dcao_hsd)
print(dcao_hsd$groups)

neon_proc_DC2 =
  neon_proc_DC %>% 
  filter(siteID %in% c("HEAL", "TOOL"))

dcao_aov2 = aov(data = neon_proc_DC2, DC_AO ~ siteID * biogeoCenterDepth)
summary(dcao_aov2)
# 
# dcao2_hsd = HSD.test(dcao_aov1,"biogeoCenterDepth")
# print(dcao2_hsd)
# print(dcao2_hsd$groups)
# 
# neon_aov1 = aov(data = neon_proc, AO_DC * ctonRatio ~ siteID)
# summary(neon_aov1)
# 
# neon_aov2 = aov(data = neon_proc, ctonRatio ~ siteID*depth)
# summary(neon_aov2)
# 
# ctonneon_hsd = HSD.test(neon_aov2,"siteID")
# print(ctonneon_hsd)
# print(ctonneon_hsd$groups)
# 
# AODCneon_hsd = HSD.test(neon_aov2,"siteID")
# print(AODCneon_hsd)
# print(AODCneon_hsd$groups)
# 
# neon_aov3 = aov(data = neon_proc, nitrogenTot ~ siteID*depth)
# summary(neon_aov3)
# 
# ntotneon_hsd = HSD.test(neon_aov3,"siteID")
# print(ntotneon_hsd)
# print(ntotneon_hsd$groups)
# 
# neon_aov4 = aov(data = neon_proc, acidity ~ siteID)
# summary(neon_aov4)
# 
# acidity_hsd = HSD.test(neon_aov4,"siteID")
# print(acidity_hsd)
# print(acidity_hsd$groups)
# 
# neon_aov5 = aov(data = neon_proc, waterSatx ~ siteID)
# summary(neon_aov5)
# 
# water_hsd = HSD.test(neon_aov5,"siteID")
# print(water_hsd)
# print(water_hsd$groups)
# 
# neon_aov6 = aov(data = neon_proc, estimatedOC ~ siteID*depth)
# summary(neon_aov6)
# 
# oc_hsd = HSD.test(neon_aov6,"depth")
# print(oc_hsd)
# print(oc_hsd$groups)
# 
# neon_aov6 = aov(data = neon_proc, AO_DC * waterSatx ~ siteID*depth)
# summary(neon_aov6)
# 
# oc_hsd = HSD.test(neon_aov6,"siteID")
# print(oc_hsd)
# print(oc_hsd$groups)

#ggplots initial processing------------------------------------------------------------
neon_proc = neon_proc %>% 
  mutate(siteID = factor (siteID, levels = c("HEAL", "BONA", "TOOL", "BARR"))) %>% 
  rename(depth = biogeoCenterDepth)

library(ggthemes)
library(gapminder)


#SOMMOS plots-----------------

sommos_twosite = 
  sommos_csv %>% 
  filter(X > 200)

sommos_twosite %>% 
  ggplot()+
  geom_point(aes(x = DC_Mn.g100g, y = midpoint_depth.cm, fill = P.uggOC), size = 5, shape = 21)+
  facet_grid(~site)+
  ylim(100,0)+
  labs(fill = "Phosphorus, ugg")+
  scale_fill_gradientn(colors = PNWColors::pnw_palette("Bay"))+
  theme_erclean()+
  theme(legend.position = 'bottom')

sommos_twosite %>% 
  ggplot()+
  geom_point(aes(x = DC_Mn.g100g, y = midpoint_depth.cm, fill = P.uggOC), size = 5, shape = 21)+
  facet_grid(~site)+
  ylim(100,0)+
  scale_fill_gradientn(colors = PNWColors::pnw_palette("Sunset"))+
  theme_erclean()+
  theme(legend.position = 'bottom')
  


sommos_twosite %>% 
  ggplot()+
  geom_point(aes(x = SP_Mn.g100g , y = midpoint_depth.cm, fill = D14C), size = 5, shape = 21)+
  facet_grid(~site)+
  ylim(100,0)+
  scale_fill_gradientn(colors = PNWColors::pnw_palette("Sunset"))+
  theme_erclean()+
  theme(legend.position = 'bottom')


#These plots are combo figures from NEON metadata---------------

#the next three plots are interesting but not currently in the manuscript. commented out but not deleted yet.
# ggplot(neon_proc, aes(y=depth, x=nitrogenTot, size = carbonTot, color=siteID)) +
#   geom_point(alpha = 0.7) +
#   scale_size(range = c(1, 10), name = "AO:DC")+
#   theme_erclean() +
#   scale_color_manual(values = rev(PNWColors::pnw_palette("Bay")))+
#   labs(y = "Depth, cm", x = "Total Nitrogen")+
#   scale_y_reverse()+
#   facet_grid(.~siteID)
# 
# ggplot(neon_proc, aes(y=depth, x=ctonRatio, size = DC_AO, color=siteID)) +
#   geom_point(alpha = 0.4) +
#   scale_size(range = c(1, 24), name = "AO:DC")+
#   theme_erclean() +
#   scale_color_manual(values = rev(PNWColors::pnw_palette("Bay")))+
#   labs(y = "Depth, cm", x = "C:N Ratio")+
#   scale_y_reverse()+
#   facet_grid(.~siteID)


 

# neon_proc %>% 
# ggplot(aes(y=depth, x=ctonRatio, color=siteID)) +
#   geom_point(alpha = 0.4, size = 5) +
#   theme_erclean() +
#   #scale_color_nord("afternoon_prarie", 4)+
#   scale_color_manual(values = rev(PNWColors::pnw_palette("Bay")))+
#   labs(y = "Depth, cm", x = "C:N Ratio")+
#   scale_y_reverse()+
#   facet_grid(.~siteID)

#figures currrently in manuscript-----------------------
#for manuscript! 10 12 2021

#Healy and Toolik only, DC:AO ratios

neon_proc_DC %>% 
  filter(siteID == c("TOOL", "HEAL")) %>% 
  # mutate(siteID = factor(siteID, levels = c("BARR", "TOOL", "BONA", "HEAL")),
  #        siteID = recode(siteID, "BARR" = "Utqiaġvik",
  #                      "TOOL" = "Toolik",
  #                      "BONA" = "Caribou Poker",
  #                      "HEAL" = "Healy")) %>% 
  mutate(siteID = factor(siteID, levels = c("HEAL", "TOOL")),
         siteID = recode(siteID, "TOOL" = "Toolik",
                         "HEAL" = "Healy")) %>% 
  ggplot(aes(y=biogeoCenterDepth, x=DC_AO, fill=siteID)) +
  geom_point(alpha = 0.4, size = 5, color = "grey10", shape = c(21)) +
  theme_er() +
  scale_fill_manual(values = rev(PNWColors::pnw_palette("Bay", 2)))+
  labs(y = "Depth, cm", x = "crystalline Fe/Al: non-crystalline Fe/Al")+
  scale_y_reverse()+
 # scale_x_log10()+
  #facet_grid(.~siteID, scales = "free_x")
  facet_grid(.~siteID)
  
#new fig for manuscript 2021 12 06

neon_proc_boxplot = 
  neon_proc_DC %>% 
  mutate(siteID = recode(siteID, "TOOL" = "Toolik",
                         "HEAL" = "Healy")) %>% 
  pivot_longer(-c(siteID, plotID, biogeoCenterDepth), names_to = "parameter", 
               values_to = "data") %>% 
  filter(biogeoCenterDepth < 80) %>% 
  dplyr::mutate(depth = case_when(biogeoCenterDepth<=10 ~ "0-10", 
         biogeoCenterDepth <= 20 ~ "10-20",
         biogeoCenterDepth <= 30 ~ "20-30",
         biogeoCenterDepth <= 40 ~ "30-40",
         biogeoCenterDepth <= 50 ~ "40-50",
         biogeoCenterDepth <= 60 ~ "50-60",
         biogeoCenterDepth <= 70 ~ "60-70",
         biogeoCenterDepth <= 80 ~ "70-80",
         ))


#manuscript figure for Rebecca

DCAO = 
  neon_proc_boxplot %>% 
  filter(siteID %in% c("Healy", "Toolik") & parameter %in% c("DC", "AO")) %>%
  mutate(siteID = factor(siteID, levels = c("Healy", "Toolik", "BONA"))) %>% 
  #        siteID = recode(siteID, "BARR" = "Utqiaġvik",
  #                      "TOOL" = "Toolik",
  #                      "BONA" = "Caribou Poker",
  #                      "HEAL" = "Healy")) %>% 
  mutate(parameter = recode(parameter, "DC" = "crystalline Fe + Al",
                            "AO" = "poorly crystalline Fe + Al")) %>% 
  mutate(depth = factor(depth, levels = c("80-90", "70-80", "60-70",
                                          "50-60", "40-50", "30-40", "20-30", "10-20", "0-10"))) %>% 
  ggplot(aes(y=depth, x=data, fill=parameter)) +
  #geom_boxplot(horizontal = TRUE) +
  geom_col(width = 0.7)+
  labs(x = "weight % of total soil")+
  scale_fill_manual(values = (PNWColors::pnw_palette("Mushroom", 2)))+
  facet_grid(.~siteID)+
  theme_er()+
  theme(legend.position = "bottom", panel.border = element_rect(color="white",size=0.5, fill = NA) 
  )+
  NULL

ggsave("output/DCAO.tiff", plot = DCAO, height = 8, width = 9)
ggsave("output/DCAO.jpeg", plot = DCAO, height = 8, width = 9)


neon_proc_boxplot %>% 
  filter(siteID %in% c("Healy", "Toolik") & parameter %in% c("DC", "AO")) %>%
  mutate(siteID = factor(siteID, levels = c("Healy", "Toolik", "BONA"))) %>% 
  #        siteID = recode(siteID, "BARR" = "Utqiaġvik",
  #                      "TOOL" = "Toolik",
  #                      "BONA" = "Caribou Poker",
  #                      "HEAL" = "Healy")) %>% 
  mutate(parameter = recode(parameter, "DC" = "Crystalline Fe/Al",
                            "AO" = "Non-crystalline Fe/Al")) %>% 
  mutate(depth = factor(depth, levels = c("100-112.5", "90-100", "80-90", "70-80", "60-70",
                                          "50-60", "40-50", "30-40", "20-30", "10-20", "0-10"))) %>% 
  ggplot(aes(y=depth, x=data, fill=parameter)) +
  #geom_boxplot(horizontal = TRUE) +
  geom_col(width = 0.7)+
  labs(x = "weight % of total soil")+
  scale_fill_manual(values = (PNWColors::pnw_palette("Mushroom", 2)))+
  facet_grid(.~siteID)+
  theme_er()+
  theme(legend.position = "bottom", panel.border = element_rect(color="white",size=0.5, fill = NA) 
  )+
  NULL


neon_proc_boxplot %>% 
  filter(siteID %in% c("Toolik", "Healy") & parameter %in% c("DC", "AO")) %>%
  # mutate(siteID = factor(siteID, levels = c("BARR", "TOOL", "BONA", "HEAL")),
  #        siteID = recode(siteID, "BARR" = "Utqiaġvik",
  #                      "TOOL" = "Toolik",
  #                      "BONA" = "Caribou Poker",
  #                      "HEAL" = "Healy")) %>% 
  mutate(parameter = recode(parameter, "DC" = "Crystalline Fe/Al",
                            "AO" = "Non-crystalline Fe/Al")) %>% 
  mutate(depth = factor(depth, levels = c("100-112.5", "90-100", "80-90", "70-80", "60-70",
                                          "50-60", "40-50", "30-40", "20-30", "10-20", "0-10"))) %>% 
  ggplot(aes(y=depth, x=data, fill=parameter)) +
  #geom_boxplot(horizontal = TRUE) +
  geom_bar(stat="identity", width=.5, position = "dodge") +
  #geom_col(width = 0.7)+
  labs(x = "weight % of total soil")+
  scale_fill_manual(values = (PNWColors::pnw_palette("Mushroom", 2)))+
  facet_grid(.~siteID)+
  theme_er()+
  theme(legend.position = "bottom", panel.border = element_rect(color="white",size=0.5, fill = NA) 
  )+
  NULL


neon_proc_boxplot %>% 
  filter(siteID %in% c("TOOL", "HEAL") & parameter %in% c('alOxalate', 'alCitDithionate')) %>%
  # mutate(siteID = factor(siteID, levels = c("BARR", "TOOL", "BONA", "HEAL")),
  #        siteID = recode(siteID, "BARR" = "Utqiaġvik",
  #                      "TOOL" = "Toolik",
  #                      "BONA" = "Caribou Poker",
  #                      "HEAL" = "Healy")) %>% 
  mutate(siteID = factor(siteID, levels = c("HEAL", "TOOL")),
         siteID = recode(siteID, "TOOL" = "Toolik",
                         "HEAL" = "Healy")) %>%
  mutate(depth = factor(depth, levels = c("100-112.5", "90-100", "80-90", "70-80", "60-70",
                                          "50-60", "40-50", "30-40", "20-30", "10-20", "0-10"))) %>% 
  ggplot(aes(y=depth, x=data, fill=parameter)) +
  geom_boxplot(horizontal = TRUE) +
  scale_fill_manual(values = rev(PNWColors::pnw_palette("Mushroom", 2)))+
  facet_grid(.~siteID)+
  theme_er()+
  NULL

neon_proc_boxplot %>% 
  filter(siteID %in% c("TOOL", "HEAL") & parameter %in% c("feOxalate", "feCitDithionate",
                                                          'alOxalate', 'alCitDithionate')) %>%
  # filter(siteID %in% c("TOOL", "HEAL") & parameter %in% c("feOxalate", "feCitDithionate")) %>%
  # mutate(siteID = factor(siteID, levels = c("BARR", "TOOL", "BONA", "HEAL")),
  #        siteID = recode(siteID, "BARR" = "Utqiaġvik",
  #                      "TOOL" = "Toolik",
  #                      "BONA" = "Caribou Poker",
  #                      "HEAL" = "Healy")) %>% 
  mutate(siteID = factor(siteID, levels = c("HEAL", "TOOL")),
         siteID = recode(siteID, "TOOL" = "Toolik",
                         "HEAL" = "Healy")) %>% 
  ggplot(aes(y=depth, x=data, fill=parameter)) +
  geom_boxplot(horizontal = TRUE) +
  theme_er()+
  facet_grid(.~siteID)+
  NULL


  scale_fill_manual(values = rev(PNWColors::pnw_palette("Bay", 2)))+
  labs(y = "Depth, cm", x = "crystalline Fe/Al: non-crystalline Fe/Al")+
  scale_y_reverse()+
  # scale_x_log10()+
  #facet_grid(.~siteID, scales = "free_x")
  facet_grid(.~siteID)

neon_proc %>% 
  filter(siteID == c("TOOL", "HEAL")) %>% 
  ggplot(aes(y=depth, x=acidity, fill=siteID)) +
  geom_point(alpha = 0.4, size = 5, color = "grey10", shape = c(21)) +
  theme_er() +
  #scale_color_nord("afternoon_prarie", 4)+
  scale_fill_manual(values = rev(PNWColors::pnw_palette("Bay", 2)))+
  labs(y = "Depth, cm", x = "Acidity")+
  scale_y_reverse()+
  facet_grid(.~siteID)
  

neon_proc %>% 
  ggplot(aes(y=depth, x=estimatedOC, color=siteID)) +
  geom_point(alpha = 0.4, size = 5) +
  theme_erclean() +
  scale_color_nord("afternoon_prarie", 4)+
  #scale_color_manual(values = rev(PNWColors::pnw_palette("Bay")))+
  labs(y = "Depth, cm", x = "Estimated OC")+
  scale_y_reverse()+
  facet_grid(.~siteID)

neon_proc %>% 
  filter(siteID == "BARR") %>% 
  ggplot(aes(x=DC_AO, y=OlsenPExtractable, fill=siteID)) +
  geom_point(alpha = 0.4, size = 5, shape = c(21), color = "grey10") +
  theme_erclean() +
  #scale_color_nord("afternoon_prarie", 4)+
  scale_fill_manual(values = rev(PNWColors::pnw_palette("Winter", 4)))+
  labs(title = "Barrow", x = "DC to AO ratio", y = "Extractable Olsen P")+
  #facet_grid(.~siteID)+
  NULL

a = neon_proc %>% 
  filter(siteID == "BARR") %>% 
  ggplot(aes(x=DC_AO, y=OlsenPExtractable, fill=siteID)) +
  geom_point(alpha = 0.4, size = 5, shape = c(21), color = "grey10") +
  theme_erclean() +
  #scale_color_nord("afternoon_prarie", 4)+
  scale_fill_manual(values = rev(PNWColors::pnw_palette("Winter", 4)))+
  labs(x = "DC:AO", y = "Extractable Olsen P, mg per kg")+
  #facet_grid(.~siteID)+
  NULL

neon_proc %>% 
  filter(siteID == "BARR") %>% 
  ggplot(aes(y=DC_AO, x=OlsenPExtractable, color=siteID)) +
  geom_point(alpha = 0.4, size = 5) +
  theme_erclean() +
  scale_color_nord("afternoon_prarie", 4)+
  #scale_color_manual(values = rev(PNWColors::pnw_palette("Bay")))+
  labs(title = "Barrow", y = "DC to AO ratio", x = "Extractable Olsen P")+
  #scale_y_reverse()+
  #facet_grid(.~siteID)+
  NULL

neon_proc %>% 
  filter(siteID == "BARR") %>% 
  ggplot(aes(x=DC_AO, y=carbonTot, fill=siteID)) +
  geom_point(alpha = 0.4, size = 5, color = "grey10", shape = c(21)) +
  theme_erclean() +
  #scale_color_nord("afternoon_prarie", 4)+
  scale_fill_manual(values = rev(PNWColors::pnw_palette("Winter", 4)))+
  labs(title = "Barrow", x = "DC to AO ratio", y = "Total Carbon")+
  #scale_y_reverse()+
  #facet_grid(.~siteID)+
  NULL

b = neon_proc %>% 
  filter(siteID == "BARR") %>% 
  ggplot(aes(x=DC_AO, y=carbonTot, fill=siteID)) +
  geom_point(alpha = 0.4, size = 5, color = "grey10", shape = c(21)) +
  theme_erclean() +
  #scale_color_nord("afternoon_prarie", 4)+
  scale_fill_manual(values = rev(PNWColors::pnw_palette("Winter", 4)))+
  labs(x = "DC:AO", y = "Total Carbon, mg per kg")+
  #scale_y_reverse()+
  #facet_grid(.~siteID)+
  NULL

###manuscriptfigure####----------------------

library(cowplot)
library(patchwork)

a+b





neon_proc %>% 
  filter(siteID == "BARR") %>% 
  ggplot(aes(y=DC_AO, x=acidity, fill=siteID)) +
  geom_point(alpha = 0.4, size = 5, shape = c(21)) +
  theme_erclean() +
  scale_color_nord("afternoon_prarie", 4)+
  #scale_color_manual(values = rev(PNWColors::pnw_palette("Bay")))+
  labs(title = "Barrow", y = "DC to AO ratio", x = "Acidity")+
  #scale_y_reverse()+
  #facet_grid(.~siteID)+
  NULL

neon_proc %>% 
  #filter(siteID == "BARR") %>% 
  ggplot(aes(y=DC_AO, x=estimatedOC, color=siteID)) +
  geom_point(alpha = 0.4, size = 5) +
  theme_erclean() +
  scale_color_nord("afternoon_prarie", 4)+
  #scale_color_manual(values = rev(PNWColors::pnw_palette("Bay")))+
  labs(y = "DC to AO ratio", x = "Estimated OC")+
  #scale_y_reverse()+
  facet_wrap(siteID~.)+
  NULL

neon_proc %>% 
  #filter(siteID == "BARR") %>% 
  ggplot(aes(y=DC_AO, x=waterSatx, color=siteID)) +
  geom_point(alpha = 0.4, size = 5) +
  theme_erclean() +
  scale_color_nord("afternoon_prarie", 4)+
  #scale_color_manual(values = rev(PNWColors::pnw_palette("Bay")))+
  labs(y = "DC to AO ratio", x = "Water Saturation")+
  #scale_y_reverse()+
  ylim(0,1.5)+
  facet_wrap(siteID~.)+
  NULL

neon_proc %>% 
ggplot() +
  geom_boxplot(aes(y=DC_AO, x=siteID, color=siteID, fill = siteID))+
  #scale_size(range = c(1, 24), name = "AO:DC")+
  theme_erclean() +
  scale_color_manual(values = rev(PNWColors::pnw_palette("Bay")))+
  scale_fill_manual(values = rev(PNWColors::pnw_palette("Bay")))+
  labs(y = "AO:DC", x = "Site")
  #scale_y_reverse()+
  #facet_grid(.~siteID)

neon_proc %>% 
  filter(depth > "75") %>% 
  ggplot() +
  geom_boxplot(aes(y=DC_AO, x=siteID, color=siteID, fill = siteID))+
  #scale_size(range = c(1, 24), name = "AO:DC")+
  theme_erclean() +
  scale_color_manual(values = rev(PNWColors::pnw_palette("Bay")))+
  scale_fill_manual(values = rev(PNWColors::pnw_palette("Bay")))+
  labs(title = "75+ cm",
       y = "AO:DC", x = "Site")
#scale_y_reverse()+
#facet_grid(.~siteID)

neon_proc %>% 
  filter(depth > "50", depth < "75") %>% 
  ggplot() +
  geom_boxplot(aes(y=DC_AO, x=siteID, color=siteID, fill = siteID))+
  #scale_size(range = c(1, 24), name = "AO:DC")+
  theme_erclean() +
  scale_color_manual(values = rev(PNWColors::pnw_palette("Bay")))+
  scale_fill_manual(values = rev(PNWColors::pnw_palette("Bay")))+
  labs(title = "50-75 cm",
       y = "AO:DC", x = "Site")
#scale_y_reverse()+
#facet_grid(.~siteID)

neon_proc %>% 
  filter(depth > "25", depth < "50") %>% 
  ggplot() +
  geom_boxplot(aes(y=DC_AO, x=siteID, color=siteID, fill = siteID))+
  #scale_size(range = c(1, 24), name = "AO:DC")+
  theme_erclean() +
  scale_color_manual(values = rev(PNWColors::pnw_palette("Bay")))+
  scale_fill_manual(values = rev(PNWColors::pnw_palette("Bay")))+
  labs(title = "25-50 cm",
       y = "AO:DC", x = "Site")
#scale_y_reverse()+
#facet_grid(.~siteID)

neon_proc %>% 
  filter(depth > "0", depth < "25") %>% 
  ggplot() +
  geom_boxplot(aes(y=AO_DC, x=siteID, color=siteID, fill = siteID))+
  #scale_size(range = c(1, 24), name = "AO:DC")+
  theme_erclean() +
  scale_color_manual(values = rev(PNWColors::pnw_palette("Bay")))+
  scale_fill_manual(values = rev(PNWColors::pnw_palette("Bay")))+
  labs(title = "0-25 cm",
       y = "AO:DC", x = "Site")
#scale_y_reverse()+
#facet_grid(.~siteID)

neon_proc %>% 
  ggplot(aes(x = (depth), fill = siteID, color = siteID))+
  geom_histogram(aes(y = stat(count)), 
                 bindwidth=5, alpha = 0.5) +
  scale_fill_nord("afternoon_prarie", 4)+
  scale_color_nord("afternoon_prarie", 4)+
  facet_wrap(.~siteID)+
  theme_er()





p1 = neon_proc %>% 
  ggplot() +
  geom_point(data = neon_proc, aes(y=depth, x=nitrogenTot, color=siteID)) +
  theme_erclean() +
  scale_color_manual(values = rev(PNWColors::pnw_palette("Bay")))+
  labs(y = "Depth, cm", x = "Total Nitrogen")+
  scale_y_reverse()+
  facet_grid(. ~ siteID)


p2 = neon_proc %>% 
  ggplot(aes(y=depth, x=estimatedOC, color=siteID)) +
  geom_point() +
  #geom_smooth(span = 0.3)+
  theme_erclean() +
  scale_color_manual(values = rev(PNWColors::pnw_palette("Bay")))+
  labs(y = NULL, x = "Organic Carbon")+
  scale_y_reverse()+
  facet_grid(. ~ siteID)

# neon_proc %>% 
#   ggplot(aes(y=depth, x=nitrogenTot, color=siteID)) +
#   geom_point() +
#   geom_smooth(span = 0.3)+
#   theme_er() +
#   scale_color_manual(values = rev(PNWColors::pnw_palette("Bay")))+
#   labs(y = "Depth, cm", x = "Total Nitrogen")+
#   scale_y_reverse()+
#   facet_grid(. ~ siteID)

p3 = neon_proc %>% 
  ggplot(aes(y=depth, x=AO_DC, color=siteID)) +
  geom_point() +
  xlim(0, 1.5)+
  #geom_smooth(span = 0.3)+
  theme_erclean() +
  scale_color_manual(values = rev(PNWColors::pnw_palette("Bay")))+
  labs(y = "Depth, cm", x = "AO to DC ratio")+
  scale_y_reverse()+
  facet_grid(. ~ siteID)

p4 = neon_proc %>% 
  ggplot(aes(y=depth, x=ctonRatio, color=siteID)) +
  geom_point() +
  #xlim(0, 1.5)+
  #geom_smooth(span = 0.3)+
  theme_erclean() +
  scale_color_manual(values = rev(PNWColors::pnw_palette("Bay")))+
  labs(y = NULL, x = "C:N ratio")+
  scale_y_reverse()+
  facet_grid(. ~ siteID)

library(patchwork)
p1+p2+p3+p4+ #combines the two plots
  plot_layout(guides = "collect") & theme_erclean()

#


neon_proc %>% 
  ggplot(aes(y=depth, x=ctonRatio, color=siteID)) +
  geom_point() +
  #xlim(0, 1.5)+
  #geom_smooth(span = 0.3)+
  theme_er() +
  scale_color_manual(values = rev(PNWColors::pnw_palette("Bay")))+
  labs(y = "Depth, cm", x = "C:N ratio")+
  scale_y_reverse()+
  facet_grid(. ~ siteID)





#

neon_proc %>% 
  ggplot() +
  geom_point(data = neon_proc, aes(y=depth, x=acidity, color=siteID)) +
  theme_er() +
  scale_color_manual(values = rev(PNWColors::pnw_palette("Bay")))+
  labs(y = "Depth, cm", x = "Acidity")+
  scale_y_reverse()+
  facet_grid(. ~ siteID)

neon_proc %>% 
  ggplot(aes(y=depth, x=waterSatx, color=siteID)) +
  geom_point() +
  #geom_smooth(span = 0.3)+
  theme_er() +
  scale_color_manual(values = rev(PNWColors::pnw_palette("Bay")))+
  labs(y = "Depth, cm", x = "Water Saturation") +
  scale_y_reverse()+
  facet_grid(. ~ siteID)
  


#Sommos ggplots

sommos_proc = sommos_proc %>% 
  mutate(site = factor (site, levels = c("HEAL", "BONA", "BARR", "TOOL")))

sommos_proc %>% 
  filter(!horizon_type == "none") %>% 
  ggplot() +
  geom_point(data = sommos_proc, aes(y=AO_DC, x=site, fill=site, color = site, size = 4)) +
  theme_er() +
  scale_color_manual(values = rev(PNWColors::pnw_palette("Bay")))+
  labs(y = "AO Extractable: DC Extractable Ratio") +
  facet_wrap(.~horizon_type)

sommos_proc %>% 
  ggplot() +
  geom_boxplot(data = sommos_proc, aes(y=SP_DC, x=site, fill=site)) +
  theme_er() +
  scale_fill_manual(values = rev(PNWColors::pnw_palette("Bay")))+
  labs(y = "SP Extractable: DC Extractable Ratio")

  
  #scale_y_continuous(trans = "reverse", breaks = (sommos_csv$top_depth.cm)) 
  #facet_grid(. ~ site)

sommos_csv %>% 
  ggplot() +
  geom_point(data = sommos_csv, aes(y=OCC.g100g, x=LIG.ugg, color=site, size=10, shape=horizon_type)) +
  theme_er() +
  scale_color_manual(values = rev(PNWColors::pnw_palette("Bay")))
  
  
#scale_y_continuous(trans = "reverse", breaks = (sommos_csv$top_depth.cm)) 
#facet_grid(. ~ site)

# sommos_csv %>% 
#   ggplot() +
#   geom_point(data = sommos_csv, aes(y=FLF.g100g, x=HF.g100g, color=site, size=OCC.g100g)) +
#   #scale_y_continuous(trans = "reverse", breaks = (sommos_csv$top_depth.cm)) +
#   theme_erclean() +
#   strip.background = element_rect(colour="black", fill="black") #facet formatting
# 
#   #facet_grid(. ~ site)

###########





