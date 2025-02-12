# Feb-24-2021
# FTICR
# Water Analysis
# Van Krevelin

#load packages
source("code/FTICR-0-packages.R")
library(wesanderson)
library(nord)

# 1. Load files-----------------------------------

fticr_data_water = read.csv("processed/fticr_data_water.csv")
fticr_meta_water = read.csv("processed/fticr_meta_water.csv")
meta_hcoc_water  = read.csv("processed/fticr_meta_hcoc_water.csv") %>% select(-Mass)
### ^^ the files above have aliph as well as aromatic for the same sample, which can be confusing/misleading
### create an index combining them

fticr_water = 
  fticr_data_water %>% 
  select(Core, formula, Site, Trtmt, Material) 

fticr_data_water_summarized = 
  fticr_water %>% 
  distinct(Site, Trtmt, Material, formula) %>% mutate(presence = 1)

# van krevelen plots_water------------------------------------------------------

fticr_water_hcoc =
  fticr_data_water_summarized %>% 
  left_join(fticr_meta_water) %>% 
  dplyr::select(formula, Site, Trtmt, Material, HC, OC, Class)

# 
gg_all = fticr_water_hcoc %>% 
  filter(Trtmt %in% "CON") %>% 
  mutate(Site = recode(Site, "TOOL" = "Toolik",
                       "HEAL" = "Healy")) %>% 
  gg_vankrev(aes(x=OC, y=HC, color = Site))+
  stat_ellipse(show.legend = F)+
  stat_ellipse()+
  labs(x = "O/C",
       y = "H/C")+
  theme_er()+
  scale_color_manual(values = pnw_palette("Bay", 2))

ggMarginal(gg_all,groupColour = TRUE, groupFill = TRUE)


fticr_water_hcoc %>% 
  mutate(Material = factor (Material, levels = c("Organic", "Upper Mineral", "Lower Mineral"))) %>% 
  ggplot(aes(x=OC, y=HC, color = Site))+
  geom_point(alpha = 0.2, size = 1)+
  stat_ellipse(show.legend = F)+
  facet_grid(Material ~.)+
  geom_segment(x = 0.0, y = 1.5, xend = 1.2, yend = 1.5,color="black",linetype="longdash") +
  geom_segment(x = 0.0, y = 0.7, xend = 1.2, yend = 0.4,color="black",linetype="longdash") +
  geom_segment(x = 0.0, y = 1.06, xend = 1.2, yend = 0.51,color="black",linetype="longdash") +
  guides(colour = guide_legend(override.aes = list(alpha=1, size=2)))+
  #ggtitle("Water extracted FTICR-MS")+
  theme_er() +
  #scale_color_manual (values = soil_palette("redox", 2))+
  NULL

fticr_water_hcoc %>% 
  mutate(Trtmt = recode(Trtmt, "CON" = "control",
                        "FTC" = "freeze-thaw"),
         Site = recode(Site, "TOOL" = "Toolik",
                       "HEAL" = "Healy")) %>% 
  mutate(Material = factor (Material, levels = c("Organic", "Upper Mineral", "Lower Mineral"))) %>% 
  ggplot(aes(x=OC, y=HC, color = Trtmt))+
  geom_point(alpha = 0.2, size = 1)+
  stat_ellipse(show.legend = F)+
  facet_grid(Material ~ Site)+
  geom_segment(x = 0.0, y = 1.5, xend = 1.2, yend = 1.5,color="black",linetype="longdash") +
  geom_segment(x = 0.0, y = 0.7, xend = 1.2, yend = 0.4,color="black",linetype="longdash") +
  geom_segment(x = 0.0, y = 1.06, xend = 1.2, yend = 0.51,color="black",linetype="longdash") +
  guides(colour = guide_legend(override.aes = list(alpha=1, size=2)))+
  labs(x = "O/C",
       y = "H/C")+
  #ggtitle("Water extracted FTICR-MS")+
  theme_er() +
  #scale_color_manual (values = soil_palette("redox", 2))+
  NULL


#van krevelen with all peaks compared by site and treatment

fticr_water_hcoc %>%
  mutate(Trtmt = recode(Trtmt, "CON" = "control",
                        "FTC" = "freeze-thaw"),
         Site = recode(Site, "TOOL" = "Toolik",
                       "HEAL" = "Healy")) %>% 
  ggplot(aes(x=OC, y=HC, color = Trtmt))+
  geom_point(alpha = 0.2, size = 1)+
  stat_ellipse(show.legend = F)+
  facet_grid(. ~ Site)+
  geom_segment(x = 0.0, y = 1.5, xend = 1.2, yend = 1.5,color="black",linetype="longdash") +
  geom_segment(x = 0.0, y = 0.7, xend = 1.2, yend = 0.4,color="black",linetype="longdash") +
  geom_segment(x = 0.0, y = 1.06, xend = 1.2, yend = 0.51,color="black",linetype="longdash") +
  guides(colour = guide_legend(override.aes = list(alpha=1, size=2)))+
  labs(color="",
       y="H/C",
       x="O/C")+
  theme_er() 


## calculate peaks lost/gained ---- 

# this does only unique loss/gain by CON vs FTC
fticr_water_ftc_loss = 
  fticr_data_water_summarized %>% 
  # calculate n to see which peaks were unique vs. common
  group_by(formula, Site, Material) %>% 
  dplyr::mutate(n = n()) %>% 
  # n = 1 means unique to CON or FTC Trtmt
  # n = 2 means common to both
  filter(n == 1) %>% 
  mutate(loss_gain = if_else(Trtmt == "CON", "lost", "gained")) %>% 
  left_join(meta_hcoc_water) %>% 
  mutate(Material = factor (Material, levels = c("Organic", "Upper Mineral", "Lower Mineral")))

fticr_water_ftc_loss_common = 
  fticr_data_water_summarized %>% 
  # calculate n to see which peaks were unique vs. common
  group_by(formula, Site, Material) %>% 
  dplyr::mutate(n = n()) %>% 
  # n = 1 means unique to CON or FTC Trtmt
  # n = 2 means common to both
  # filter(n == 1) %>% 
  mutate(loss_gain = case_when(n == 2 ~ "common",
                               (n == 1 & Trtmt == "CON") ~ "lost",
                               (n == 1 & Trtmt == "FTC") ~ "gained")) %>% 
  left_join(meta_hcoc_water) %>% 
  mutate(Material = factor (Material, levels = c("Organic", "Upper Mineral", "Lower Mineral")))

# plot only lost/gained
# fticr_water_ftc_loss %>% 
#   mutate(Site = recode(Site, "TOOL" = "Toolik",
#                        "HEAL" = "Healy"),
#          loss_gain = recode(loss_gain, "lost" = "control",
#                             "gained" = "freeze-thaw")) %>% 
#   filter(Site == "Healy") %>% 
#   ggplot(aes(x = OC, y = HC, color = loss_gain))+
#   geom_point(alpha = 0.2, size = 1)+
#   stat_ellipse(show.legend = F)+
#   geom_segment(x = 0.0, y = 1.5, xend = 1.2, yend = 1.5,color="black",linetype="longdash") +
#   geom_segment(x = 0.0, y = 0.7, xend = 1.2, yend = 0.4,color="black",linetype="longdash") +
#   geom_segment(x = 0.0, y = 1.06, xend = 1.2, yend = 0.51,color="black",linetype="longdash") +
#   guides(colour = guide_legend(override.aes = list(alpha=1, size=2)))+
#   labs(
#        y = "H:C",
#        x = "O:C")+
#   facet_grid(Material ~ Site)+
#   theme_er() +
#   #scale_color_manual(values = pnw_palette("Bay", 2))+
#   #scale_color_manual(values = c("#02c39a", "#b1a7a6"))+
#   theme(legend.position = "bottom")
#   #scale_color_manual(values = wes_palette("GrandBudapest1", 2))

#ggMarginal by site, currently not used so commented out

# healy = fticr_water_ftc_loss %>% 
#   mutate(Site = recode(Site, "TOOL" = "Toolik",
#                        "HEAL" = "Healy"),
#          loss_gain = recode(loss_gain, "lost" = "control",
#                             "gained" = "freeze-thaw")) %>% 
#   filter(Site == "Healy") %>% 
#   ggplot(aes(x = OC, y = HC, color = loss_gain))+
#   geom_point(alpha = 0.2, size = 1)+
#   stat_ellipse(show.legend = F)+
#   geom_segment(x = 0.0, y = 1.5, xend = 1.2, yend = 1.5,color="black",linetype="longdash") +
#   geom_segment(x = 0.0, y = 0.7, xend = 1.2, yend = 0.4,color="black",linetype="longdash") +
#   geom_segment(x = 0.0, y = 1.06, xend = 1.2, yend = 0.51,color="black",linetype="longdash") +
#   guides(colour = guide_legend(override.aes = list(alpha=1, size=2)))+
#   labs(
#     y = "H/C",
#     x = "O/C",
#     color = "peaks unique to:")+
#   theme_er() +
#   #scale_color_manual(values = pnw_palette("Bay", 2))+
#   #scale_color_manual(values = c("#02c39a", "#b1a7a6"))+
#   theme(legend.position = "bottom")
# #scale_color_manual(values = wes_palette("GrandBudapest1", 2))
# 
# a = ggMarginal(healy,groupColour = TRUE, groupFill = TRUE)
# a

# toolik = fticr_water_ftc_loss %>% 
#   mutate(Site = recode(Site, "TOOL" = "Toolik",
#                        "HEAL" = "Healy"),
#          loss_gain = recode(loss_gain, "lost" = "control",
#                             "gained" = "freeze-thaw")) %>% 
#   filter(Site == "Toolik") %>% 
#   ggplot(aes(x = OC, y = HC, color = loss_gain))+
#   geom_point(alpha = 0.2, size = 1)+
#   stat_ellipse(show.legend = F)+
#   geom_segment(x = 0.0, y = 1.5, xend = 1.2, yend = 1.5,color="black",linetype="longdash") +
#   geom_segment(x = 0.0, y = 0.7, xend = 1.2, yend = 0.4,color="black",linetype="longdash") +
#   geom_segment(x = 0.0, y = 1.06, xend = 1.2, yend = 0.51,color="black",linetype="longdash") +
#   guides(colour = guide_legend(override.aes = list(alpha=1, size=2)))+
#   labs(
#     y = "H/C",
#     x = "O/C",
#     color = "peaks unique to:")+
#   theme_er() +
#   #scale_color_manual(values = pnw_palette("Bay", 2))+
#   #scale_color_manual(values = c("#02c39a", "#b1a7a6"))+
#   theme(legend.position = "bottom")
# #scale_color_manual(values = wes_palette("GrandBudapest1", 2))
# 
# b = ggMarginal(toolik,groupColour = TRUE, groupFill = TRUE)
# 
# b
# a

# library(cowplot)
# library(patchwork)
# a + b + plot_layout(guides = "collect")


## calculate peaks unique peaks by site ---- 

# this does only unique by site
fticr_uniquesite = 
  fticr_data_water_summarized %>% 
  filter(Trtmt == "CON") %>% 
  # calculate n to see which peaks were unique vs. common
  group_by(formula, Material) %>% 
  dplyr::mutate(n = n()) %>% 
  # n = 1 means unique to site
  # n = 2 means common to both
  mutate(unique = case_when(n == 1 ~ Site, 
                            n == 2 ~ "common")) %>% 
  left_join(meta_hcoc_water) %>% 
  mutate(Material = factor (Material, levels = c("Organic", "Upper Mineral", "Lower Mineral"))) %>% 
  mutate(Site = recode(Site, "TOOL" = "Toolik",
                       "HEAL" = "Healy"))


# plot only unique
fticr_uniquesite %>%
  filter(!unique == "common") %>% 
  gg_vankrev(aes(x = OC, y = HC, color = unique))+
  stat_ellipse(show.legend = F)+
  labs(x = 'O:C',
       y = "H:C")+
  facet_grid(Material ~ .)+
  theme_er() +
  #scale_color_manual(values = c("#bf9bdd", "#64a8a8"))+
  scale_color_manual(values = c("#e69b99", "#64a8a8"))+
  theme(legend.position = "bottom")
  #scale_color_nord(palette = "lake_superior", reverse = TRUE)
 # scale_color_manual (values = rev(nord_palettes("aurora", 2)))

#Van Krevelin with marginal distribution plot

# plot common as well as lost/gained
gg_fm = fticr_water_ftc_loss %>%
  mutate(Trtmt = recode(Trtmt, "CON" = "control",
                       "FTC" = "freeze-thaw"),
         Site = recode(Site, "TOOL" = "Toolik",
                       "HEAL" = "Healy")) %>% 
  gg_vankrev(aes(x = OC, y = HC, color = Trtmt))+
  #geom_point(alpha = 0.2, size = 1)+
  stat_ellipse(show.legend = F)+
  geom_segment(x = 0.0, y = 1.5, xend = 1.2, yend = 1.5,color="black",linetype="longdash") +
  geom_segment(x = 0.0, y = 0.7, xend = 1.2, yend = 0.4,color="black",linetype="longdash") +
  geom_segment(x = 0.0, y = 1.06, xend = 1.2, yend = 0.51,color="black",linetype="longdash") +
  guides(colour = guide_legend(override.aes = list(alpha=1, size=2)))+
  #labs(caption = "grey = common to both")+
  #scale_color_manual(values = pnw_palette("Winter", 2))+
  facet_grid(.~Site)+
  theme_er() +
  labs(color="Peaks unique to:")


ggMarginal(gg_fm,groupColour = TRUE, groupFill = TRUE)

#Van Krevelen only


#line segment plots

library(tibble)
gglabel = tribble(
  ~Site, ~Material, ~x, ~y, ~label,
  "Healy", "Organic", 0.45, 2.8, "lost = 410, gained = 441",
  "Healy", "Upper Mineral", 0.45, 2.8, "lost = 211, gained = 477",
  "Healy", "Lower Mineral", 0.45, 2.8, "lost = 646, gained = 84",
  "Toolik", "Organic", 0.45, 2.8, "lost = 166, gained = 844",
  "Toolik", "Upper Mineral", 0.45, 2.8, "lost = 356, gained = 239",
  "Toolik", "Lower Mineral", 0.45, 2.8, "lost = 223, gained = 372"
  
)

gglabel =
  gglabel %>% 
  mutate(Material = factor (Material, levels = c("Organic", "Upper Mineral", "Lower Mineral")))

gglabel2 = tribble(
  ~Site, ~Material, ~x, ~y, ~label,
  "Healy", "Lower Mineral", 0.2, 1.75, "aliphatic",
  "Healy", "Lower Mineral", 0.2, 1.25, "lignin-like",
  "Healy", "Lower Mineral", 0.2, 0.85, "aromatic",
  "Healy", "Lower Mineral", 0.3, 0.35, "condensed aromatic",
)

gglabel2 =
  gglabel2 %>% 
  mutate(Material = factor (Material, levels = c("Organic", "Upper Mineral", "Lower Mineral")))

color1 = fticr_water_ftc_loss %>%
  mutate(Trtmt = recode(Trtmt, "CON" = "lost",
                        "FTC" = "gained"),
         Site = recode(Site, "TOOL" = "Toolik",
                       "HEAL" = "Healy")) %>% 
  gg_vankrev(aes(x = OC, y = HC, color = Trtmt))+
  #geom_point(alpha = 0.2, size = 1)+
  stat_ellipse(show.legend = F)+
  geom_segment(x = 0.0, y = 1.5, xend = 1.2, yend = 1.5,color="black",linetype="longdash") +
  geom_segment(x = 0.0, y = 0.7, xend = 1.2, yend = 0.4,color="black",linetype="longdash") +
  geom_segment(x = 0.0, y = 1.06, xend = 1.2, yend = 0.51,color="black",linetype="longdash") +
  guides(colour = guide_legend(override.aes = list(alpha=1, size=2)))+
  geom_text(data = gglabel, aes(x = x, y = y, label = label), color = "black", size = 3.5)+
  #geom_text(data = gglabel2, aes(x = x, y = y, label = label), color = "black", size = 3.5)+
  labs(color = "")+
  ylim(0.0, 3.0)+
  scale_color_manual(values = pnw_palette("Cascades", 2))+
  facet_grid(Material ~ Site)+
  theme_er() +
  theme(panel.border = element_rect(color="black",size=0.5, fill = NA), 
  )

color2 = fticr_water_ftc_loss %>%
  mutate(Trtmt = recode(Trtmt, "CON" = "lost",
                        "FTC" = "gained"),
         Site = recode(Site, "TOOL" = "Toolik",
                       "HEAL" = "Healy")) %>% 
  gg_vankrev(aes(x = OC, y = HC, color = Trtmt))+
  #geom_point(alpha = 0.2, size = 1)+
  stat_ellipse(show.legend = F)+
  geom_segment(x = 0.0, y = 1.5, xend = 1.2, yend = 1.5,color="black",linetype="longdash") +
  geom_segment(x = 0.0, y = 0.7, xend = 1.2, yend = 0.4,color="black",linetype="longdash") +
  geom_segment(x = 0.0, y = 1.06, xend = 1.2, yend = 0.51,color="black",linetype="longdash") +
  guides(colour = guide_legend(override.aes = list(alpha=1, size=2)))+
  geom_text(data = gglabel, aes(x = x, y = y, label = label), color = "black", size = 3.5)+
  #geom_text(data = gglabel2, aes(x = x, y = y, label = label), color = "black", size = 3.5)+
  labs(color = "")+
  ylim(0.0, 3.0)+
  # scale_color_manual(values = c("#e69b99", "#64a8a8"))+
  # scale_color_manual(values = c("#c67b6f", "#9e6374"))+
  scale_color_manual(values = c("#c67b6f", "#efbc82"))+
  facet_grid(Material ~ Site)+
  theme_er() +
  theme(panel.border = element_rect(color="black",size=0.5, fill = NA), 
  )

color3 = fticr_water_ftc_loss %>%
  mutate(Trtmt = recode(Trtmt, "CON" = "lost",
                        "FTC" = "gained"),
         Site = recode(Site, "TOOL" = "Toolik",
                       "HEAL" = "Healy")) %>% 
  gg_vankrev(aes(x = OC, y = HC, color = Trtmt))+
  #geom_point(alpha = 0.2, size = 1)+
  stat_ellipse(show.legend = F)+
  geom_segment(x = 0.0, y = 1.5, xend = 1.2, yend = 1.5,color="black",linetype="longdash") +
  geom_segment(x = 0.0, y = 0.7, xend = 1.2, yend = 0.4,color="black",linetype="longdash") +
  geom_segment(x = 0.0, y = 1.06, xend = 1.2, yend = 0.51,color="black",linetype="longdash") +
  guides(colour = guide_legend(override.aes = list(alpha=1, size=2)))+
  geom_text(data = gglabel, aes(x = x, y = y, label = label), color = "black", size = 3.5)+
  #geom_text(data = gglabel2, aes(x = x, y = y, label = label), color = "black", size = 3.5)+
  labs(color = "")+
  ylim(0.0, 3.0)+
  # scale_color_manual(values = c("#e69b99", "#64a8a8"))+
  # scale_color_manual(values = c("#c67b6f", "#9e6374"))+
  scale_color_manual(values = c("#c67b6f", "#fbdfa2"))+
  facet_grid(Material ~ Site)+
  theme_er() +
  theme(panel.border = element_rect(color="black",size=0.5, fill = NA), 
  )

color4 = fticr_water_ftc_loss %>%
  mutate(Trtmt = recode(Trtmt, "CON" = "lost",
                        "FTC" = "gained"),
         Site = recode(Site, "TOOL" = "Toolik",
                       "HEAL" = "Healy")) %>% 
  gg_vankrev(aes(x = OC, y = HC, color = Trtmt))+
  #geom_point(alpha = 0.2, size = 1)+
  stat_ellipse(show.legend = F)+
  geom_segment(x = 0.0, y = 1.5, xend = 1.2, yend = 1.5,color="black",linetype="longdash") +
  geom_segment(x = 0.0, y = 0.7, xend = 1.2, yend = 0.4,color="black",linetype="longdash") +
  geom_segment(x = 0.0, y = 1.06, xend = 1.2, yend = 0.51,color="black",linetype="longdash") +
  guides(colour = guide_legend(override.aes = list(alpha=1, size=2)))+
  geom_text(data = gglabel, aes(x = x, y = y, label = label), color = "black", size = 3.5)+
  #geom_text(data = gglabel2, aes(x = x, y = y, label = label), color = "black", size = 3.5)+
  labs(color = "")+
  ylim(0.0, 3.0)+
  # scale_color_manual(values = c("#e69b99", "#64a8a8"))+
  # scale_color_manual(values = c("#c67b6f", "#9e6374"))+
  scale_color_manual(values = c("#537380", "#BCC2C6"))+
  facet_grid(Material ~ Site)+
  theme_er() +
  theme(panel.border = element_rect(color="black",size=0.5, fill = NA), 
  )

color6 = fticr_water_ftc_loss %>%
  mutate(Trtmt = recode(Trtmt, "CON" = "lost",
                        "FTC" = "gained"),
         Site = recode(Site, "TOOL" = "Toolik",
                       "HEAL" = "Healy")) %>% 
  gg_vankrev(aes(x = OC, y = HC, color = Trtmt))+
  #geom_point(alpha = 0.2, size = 1)+
  stat_ellipse(show.legend = F)+
  geom_segment(x = 0.0, y = 1.5, xend = 1.2, yend = 1.5,color="black",linetype="longdash") +
  geom_segment(x = 0.0, y = 0.7, xend = 1.2, yend = 0.4,color="black",linetype="longdash") +
  geom_segment(x = 0.0, y = 1.06, xend = 1.2, yend = 0.51,color="black",linetype="longdash") +
  guides(colour = guide_legend(override.aes = list(alpha=1, size=2)))+
  geom_text(data = gglabel, aes(x = x, y = y, label = label), color = "black", size = 3.5)+
  #geom_text(data = gglabel2, aes(x = x, y = y, label = label), color = "black", size = 3.5)+
  labs(color = "")+
  ylim(0.0, 3.0)+
  # scale_color_manual(values = c("#e69b99", "#64a8a8"))+
  # scale_color_manual(values = c("#c67b6f", "#9e6374"))+
  scale_color_manual(values = c("#2f9bbf", "#f0a7a0"))+
  facet_grid(Material ~ Site)+
  theme_er() +
  theme(panel.border = element_rect(color="black",size=0.5, fill = NA), 
  )


ggsave("output/color1.jpeg", plot = color1, height = 9, width = 5.5)
ggsave("output/color2.jpeg", plot = color2, height = 9, width = 5.5)
ggsave("output/color3.jpeg", plot = color3, height = 9, width = 5.5)
ggsave("output/color4.jpeg", plot = color4, height = 9, width = 5.5)
ggsave("output/color5.jpeg", plot = color5, height = 9, width = 5.5)
ggsave("output/color6.jpeg", plot = color6, height = 9, width = 5.5)





vankrev = fticr_water_ftc_loss %>%
  mutate(Trtmt = recode(Trtmt, "CON" = "lost",
                        "FTC" = "gained"),
         Site = recode(Site, "TOOL" = "Toolik",
                       "HEAL" = "Healy")) %>% 
  gg_vankrev(aes(x = OC, y = HC, color = Trtmt))+
  #geom_point(alpha = 0.2, size = 1)+
  stat_ellipse(show.legend = F)+
  geom_segment(x = 0.0, y = 1.5, xend = 1.2, yend = 1.5,color="black",linetype="longdash") +
  geom_segment(x = 0.0, y = 0.7, xend = 1.2, yend = 0.4,color="black",linetype="longdash") +
  geom_segment(x = 0.0, y = 1.06, xend = 1.2, yend = 0.51,color="black",linetype="longdash") +
  guides(colour = guide_legend(override.aes = list(alpha=1, size=2)))+
  geom_text(data = gglabel, aes(x = x, y = y, label = label), color = "black", size = 3.5)+
  #geom_text(data = gglabel2, aes(x = x, y = y, label = label), color = "black", size = 3.5)+
  labs(color = "")+
  ylim(0.0, 3.0)+
  #scale_color_manual(values = c("#698DDB", "#EDC2CC"))+
  scale_color_manual(values = c("#2f9bbf", "#f0a7a0"))+
  facet_grid(Material ~ Site)+
  theme_er() +
  theme(panel.border = element_rect(color="black",size=0.5, fill = NA), 
        )

ggsave("output/vankrev.tiff", plot = vankrev, height = 8, width = 5.5)
ggsave("output/vankrev.jpeg", plot = vankrev, height = 8, width = 5.5)


vankrev_method = 
fticr_water_hcoc %>%
  filter(Site %in% "TOOL " & Class != "other") %>% 
  # mutate(Trtmt = recode(Trtmt, "CON" = "lost",
  #                       "FTC" = "gained"),
  #        Site = recode(Site, "TOOL" = "Toolik",
  #                      "HEAL" = "Healy")) %>% 
  gg_vankrev(aes(x = OC, y = HC, color = Class, alpha = 0.4))+
  #stat_ellipse(show.legend = F)+
  geom_segment(x = 0.0, y = 1.5, xend = 1.2, yend = 1.5,color="black",linetype="longdash") +
  geom_segment(x = 0.0, y = 0.7, xend = 1.2, yend = 0.4,color="black",linetype="longdash") +
  geom_segment(x = 0.0, y = 1.06, xend = 1.2, yend = 0.51,color="black",linetype="longdash") +
  # guides(colour = guide_legend(override.aes = list(alpha=1, size=2)))+
  # geom_text(data = gglabel, aes(x = x, y = y, label = label), color = "black", size = 3.5)+
  geom_text(data = gglabel2, aes(x = x, y = y, label = label), color = "black", size = 3.5)+
  labs(color = "")+
  ylim(0.0, 2.25)+
  scale_color_manual(values = wes_palette("Darjeeling1"))+
  #facet_grid(Material ~ Site)+
  theme_er() +
  theme(panel.border = element_rect(color="black",size=0.5, fill = NA),
          legend.position = "none" 
  )

ggsave("output/vankrev_method.tiff", plot = vankrev_method, height = 4, width = 4)
ggsave("output/vankrev_method.jpeg", plot = vankrev_method, height = 4, width = 4)


#ggsave()

mean_oc = fticr_water_ftc_loss %>% 
  group_by(Site, Material, Trtmt) %>% 
  dplyr::summarise(mean = mean(OC))

mean_hc = fticr_water_ftc_loss %>% 
  group_by(Site, Material, Trtmt) %>% 
  dplyr::summarise(mean = mean(HC))

write.csv(mean_oc, "output/mean_oc.csv", row.names = FALSE)
write.csv(mean_hc, "output/mean_hc.csv", row.names = FALSE)
