#!/usr/bin/env Rscript
# -*- coding: utf-8 -*-

library(tools)
library(rjson)
library(ggplot2)
library(tikzDevice)
library(reshape2)

plot_shallow_metrics <- function(input_glob="./predictions/*/*.json"){
  files <- Sys.glob(input_glob)
  collection <- lapply(1:length(files), function(i){
    data <- fromJSON(file = files[i])
    data_name = basename(files[i])
    model_name = basename(dirname(files[i]))
    filtered <- data.frame(do.call(rbind, lapply(data, function(x) {
      as.numeric(x[4:7])})))
    names(filtered) <- names(data[[1]])[4:7]
    if (grepl("ar", data_name)) {
      data_name <- "WMT-AR"
    }
    else {
      data_name <- "WMT-Legacy"
    }
    if (grepl("hub", model_name)){
      model_name <- "FAIR SOTA Transformer"
    }
    else {
      model_name <- "Local Transformer"
    }
    filtered <- cbind(model_name, data_name, filtered)
    return(filtered)
  })
  collection <- do.call(rbind, collection)
  hold_out <- collection[-c(3,4)]
  collection <- collection[-c(5,6)]
  names(collection)[c(3,4)] <- c("Source", "Target")
  collection["Type"] <- "chrF"
  names(hold_out)[c(3,4)] <- c("Source", "Target")
  hold_out["Type"] <- "BLEU"
  collection <- rbind(collection, hold_out)
  # first plot
  metric = "chrF"
  tikz(paste0(metric, ".tex"), width=15, height=13, standAlone = TRUE)
  g <- ggplot(subset(collection, Type==metric), aes(x=Source, y=Target)) +
    geom_point(color="red", alpha=0.2, size=3) +
    theme_bw() +
    theme(text = element_text(size=25),
          legend.position = "none",
          strip.background = element_blank(),
          panel.grid = element_line(size = 1)) +
    facet_grid(data_name ~ model_name) +
    ylab(paste("Target",metric,"\n")) +
    xlab(paste("\n","Source",metric))
  print(g)
  dev.off()
  texi2pdf(paste0(metric,".tex"),clean=TRUE)
  file.remove(paste0(metric,".tex"))
  file.rename(paste0(metric,".pdf"), paste0("./img/", metric, ".pdf"))
  # second plot
  metric = "BLEU"
  tikz(paste0(metric, ".tex"), width=15, height=13, standAlone = TRUE)
  g <- ggplot(subset(collection, Type==metric), aes(x=Source, y=Target)) +
    geom_point(color="blue", alpha=0.2, size=3) +
    theme_bw() +
    theme(text = element_text(size=25),
          legend.position = "none",
          strip.background = element_blank(),
          panel.grid = element_line(size = 1)) +
    facet_grid(data_name ~ model_name) +
    ylab(paste("Target",metric,"\n")) +
    xlab(paste("\n","Source",metric))
  print(g)
  dev.off()
  texi2pdf(paste0(metric,".tex"),clean=TRUE)
  file.remove(paste0(metric,".tex"))
  file.rename(paste0(metric,".pdf"), paste0("./img/", metric, ".pdf"))
}

plot_shallow_metrics()
