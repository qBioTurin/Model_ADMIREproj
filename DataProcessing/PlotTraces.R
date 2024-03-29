library(ggplot2)
library(dplyr)
library(patchwork)

files = list.files(path = "Clustering/Data/",pattern = "*.csv",full.names = T)

DeltasList = lapply(files, function(x) {
  Deltas <- read.csv(x)
  d1 = Deltas %>% 
    dplyr::select(ts,io_p,mpi_p,other_p) %>%
    tidyr::gather(io_p,mpi_p,other_p,value = "Value",key = "States") %>%
    mutate( Processes = gsub(x = basename(x), replacement = "",pattern = "(QE_)|(Deltas.csv)"),
            Type = "Percentages")%>%
    na.omit() %>%
    rename(X= ts)
  d2 = Deltas %>% 
    mutate(other_hit = iops+mpi_hit) %>%
    dplyr::select(ts,iops,mpi_hit,other_hit) %>%
    tidyr::gather(iops,other_hit,mpi_hit,value = "Value",key = "States") %>%
    mutate( Processes = gsub(x = basename(x), replacement = "",pattern = "(QE_)|(Deltas.csv)"),
            Type = "Hits")%>%
    na.omit() %>%
    rename(X= ts)
  
  return(
    rbind(d1,d2)
  )
})

Deltas = do.call("rbind",DeltasList) 
Deltas$Processes = factor(Deltas$Processes,
                          labels = paste0(c("4","8","16","32","36" )," processes"),
                          levels = c("4","8","16","32","36" ))
Deltas$States = factor(Deltas$States,
                          labels = c("other","mpi","io","other","mpi","io"),
                          levels = c(paste0(c("other","mpi","io"),"_p"),"other_hit","mpi_hit","iops") )

#c("#FFDB6D", "#C4961A", "#F4EDCA", 
#  "#D16103", "#C3D7A4", "#52854C", "#4E84C4", "#293352")
           
p1 = Deltas %>% filter(Type != "Hits") %>%
  ggplot() +
  geom_bar(aes(x = X, y = Value, fill = States,col= States),alpha=0.6,stat="identity") +
  facet_grid(~Processes,scales = "free") +
  theme_bw()+
  labs(x= "Time (seconds)",
       y = paste0("Average percetages \nper single process in 10 seconds"),
       title = "")+
  scale_fill_manual(values = c("#C3D7A4","#4E84C4","#D16103"))+
  scale_color_manual(values = c("#C3D7A4","#4E84C4","#D16103"))+
  theme(legend.position = "bottom")
  
p2 = Deltas %>% filter(Type == "Hits") %>%
  ggplot() +
  geom_line(aes(x = X, y = Value, col= States)) +
  facet_grid(~Processes,scales = "free") +
  theme_bw()+
  labs(x= "Time (seconds)",
       y = "Average numbre of calls \nper single process in 10 seconds",
       title = "")+
  scale_color_manual(values = c("#C3D7A4","#4E84C4","#D16103"))+
theme(legend.position = "none")

combined = p1 / p2 
combined

ggsave(,filename = "traces.pdf",
       device = "pdf",
       width = 10,height = 8)

