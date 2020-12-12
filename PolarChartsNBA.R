#devtools::install_github("abresler/nbastatR")
library("dplyr")
library("tidyr")
library("stringr")
library("nbastatR")
library("ggplot2")

#https://twitter.com/FootballSlices/status/1337063082368102402

if(!exists("dataBREFPlayerAdvanced")) {
  bref_players_stats(
    seasons = 2020:2020, 
    tables = c("advanced", "per_game"),
    join_data = T
  )
}

perc.rank <- function(x) trunc(rank(x))/length(x)

playerStats <- inner_join(dataBREFPlayerAdvanced, dataBREFPlayerPerGame, by="slugPlayerSeason", suffix=c("", "perGm"))

pctRnksPlayers <- playerStats %>%
  mutate(groupPosition=case_when(
    str_detect(slugPosition, "PG") ~ "Guard",
    str_detect(slugPosition, "SG") ~ "Guard",
    str_detect(slugPosition, "SF") ~ "Wing",
    str_detect(slugPosition, "PF") ~ "Wing",
    str_detect(slugPosition, "C") ~  "Center",
  )) %>% 
  group_by(groupPosition) %>%
  select(groupPosition, namePlayer, agePlayer, slugTeamBREF, minutes, slugSeason,
         pctUSG, pct3PRate, pctFTRate, pctTrueShooting, ptsPerGame,
         pctAST, pctSTL,
         pctBLK, pctTOV,
         pctORB, pctDRB) %>%
  mutate_at(vars(pctUSG:pctDRB), perc.rank) %>%
  ungroup() %>%
  gather(., statistic, pctRnk, pctUSG:pctDRB, factor_key=TRUE)


polar.graph <- function(playerNameParam) {
  plyrToShow <- pctRnksPlayers %>% filter(str_detect(namePlayer, playerNameParam))
  plyrToShow
  # Create a simple column chart using the data frame, colored by statistic
  polar <- ggplot(plyrToShow,
                  aes(x=statistic, y=pctRnk, fill=factor(statistic), label=sprintf("%1.0f", 100*pctRnk))) + 
                  geom_col(width = 1, color = "white") +
                  geom_text(aes(y=pctRnk+0.05)) +
                  scale_x_discrete(position = 'top') + 
                  scale_y_continuous()
  # Convert the coordinate system to polar
  polar <- polar + coord_polar(clip = "off")
  # Add descriptive text to the plot
  polar <- polar + labs(
    x = "",
    y = "",
    title=plyrToShow$namePlayer,
    subtitle = paste0("Percentile ranks vs other ", plyrToShow$groupPosition, "s", "\n",
                      "Age: ", plyrToShow$agePlayer, "\n",
                      "Season: ", plyrToShow$slugSeason, "\n",
                     "Team: ", plyrToShow$slugTeamBREF, "\n",
                     "Minutes: ", plyrToShow$minutes
              ),
    caption = paste0("Data Source: Basketball Reference\n",
                     "Chart Souce: mikeroher.shinyapps.io/basketball_slices\n",
                     "Last Updated: ", format(Sys.time(), "%d-%b-%Y")
              )
  ) 
  
  # Clean up and theme the plot
  polar <- polar + 
    # Assign the ggplot2 minimal theme
    theme_minimal() +
    
    # Remove legend, axes, text, and tick marks
    theme(
      legend.position = "none",
      axis.title.x = element_blank(),
      axis.title.y = element_blank(),
      axis.ticks = element_blank(),
      axis.text.y = element_blank(),
      axis.text.x = element_text(face = "bold", hjust=31),
      plot.title = element_text(size = 24, face = "bold"),
      plot.subtitle = element_text(size = 12),
      plot.margin = margin(0,0,0,0, "cm")
    ) 
  return(polar)
}
