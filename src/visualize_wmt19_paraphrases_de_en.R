#!/usr/bin/env Rscript
# -*- coding: utf-8 -*-

library(tools)
library(rjson)
library(ggplot2)
library(tikzDevice)
library(optparse)
library(ggpointdensity)
library(viridis)

every_nth <- function(x, nth, empty = TRUE, inverse = FALSE)
# can be used to generate additional ticks
# source: https://stackoverflow.com/a/34533473
{
  x = format(x)
  if (!inverse) {
    if(empty) {
      x[1:nth == 1] <- ""
      x
    } else {
      x[1:nth != 1]
    }
  } else {
    if(empty) {
      x[1:nth != 1] <- ""
      x
    } else {
      x[1:nth == 1]
    }
  }
}

plot_shallow_metrics <- function(input_glob){
  # internal re-usable plot function
  internal_plot <- function(metric, custom_breaks){
    if(!is.null(custom_breaks)){
      g <- ggplot(subset(collection, Type==metric), aes(x=Source, y=Target)) +
        geom_pointdensity(adjust=0.7) +
        theme_bw() +
        theme(text = element_text(size=25),
              strip.background = element_blank(),
              legend.key.height = unit(3, "cm"),
              strip.text = element_text(face="bold"),
              panel.grid = element_line(size = 1),
              axis.ticks.length=unit(.15, "cm"),
              legend.margin=margin(c(1,5,5,15))) +
        scale_x_continuous(breaks = custom_breaks,
                           labels = every_nth(custom_breaks, 5, inverse=TRUE)) +
        scale_y_continuous(breaks = custom_breaks,
                           labels = every_nth(custom_breaks, 5, inverse=TRUE)) +
        facet_grid(data_name ~ model_name) +
        scale_color_viridis(name="Point\nDensity") +
        ylab(paste0("Target"," \\textit{",metric,"} [En]","\n")) +
        xlab(paste0("\n","Source"," \\textit{",metric,"} [De]"))
    } else {
      g <- ggplot(subset(collection, Type==metric), aes(x=Source, y=Target)) +
        geom_pointdensity(adjust=0.7) +
        theme_bw() +
        theme(text = element_text(size=25),
              strip.background = element_blank(),
              legend.key.height = unit(3, "cm"),
              strip.text = element_text(face="bold"),
              panel.grid = element_line(size = 1),
              axis.ticks.length=unit(.15, "cm"),
              legend.margin=margin(c(1,5,5,15))) +
        facet_grid(data_name ~ model_name) +
        scale_color_viridis(name="Point\nDensity") +
        ylab(paste0("Target"," \\textit{",metric,"} [En]","\n")) +
        xlab(paste0("\n","Source"," \\textit{",metric,"} [De]"))
    }
    return(g)
  }
  files <- Sys.glob(input_glob)
  collection <- lapply(1:length(files), function(i){
    data <- fromJSON(file = files[i])
    data_name = basename(files[i])
    model_name = basename(dirname(files[i]))
    filtered <- data.frame(do.call(rbind, lapply(data, function(x) {
      as.numeric(x[4:7])})))
    names(filtered) <- names(data[[1]])[4:7]
    if (grepl("ar", data_name)) {
      data_name <- "WMT19 Test AR"
    }
    else {
      data_name <- "WMT19 Test Legacy"
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
  # first plot with chrf
  metric = "chrF"
  custom_breaks <- seq(0.00, 1.00, 0.05)
  tikz(paste0(metric, ".tex"), width=15, height=10, standAlone = TRUE)
  g <- internal_plot(metric, NULL)
  print(g)
  dev.off()
  texi2pdf(paste0(metric,".tex"),clean=TRUE)
  file.remove(paste0(metric,".tex"))
  file.rename(paste0(metric,".pdf"), paste0("./img/", metric, ".pdf"))
  unlink(paste0(metric,"*png"))
  # second plot with BLEU
  metric = "BLEU"
  custom_breaks <- seq(0, 100, 5)
  tikz(paste0(metric, ".tex"), width=15, height=10, standAlone = TRUE)
  g <- internal_plot(metric, NULL)
  print(g)
  dev.off()
  texi2pdf(paste0(metric,".tex"),clean=TRUE)
  file.remove(paste0(metric,".tex"))
  file.rename(paste0(metric,".pdf"), paste0("./img/", metric, ".pdf"))
  unlink(paste0(metric,"*png"))
}

# parse command-line arguments
parser <- OptionParser()
parser <- add_option(parser, c("-s", "--shallow"), action="store_true",
                     help="Flag for plotting shallow metrics")
parser <- add_option(parser, c("-j", "--json-glob"),
                     type="character",
                     default="./predictions/*/*.json",
                     help="Glob for finding input jsons [default: %default]")
args <- parse_args(parser)
if(args$s){
  plot_shallow_metrics(args$j)
}
