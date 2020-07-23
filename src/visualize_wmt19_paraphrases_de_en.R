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
  internal_plot <- function(custom_breaks){
    # compute summary statistics
    means <- aggregate(subcollection[c("Source","Target")],
                       by=subcollection[c("model_name", "data_name")], FUN=mean)
    groups <- split(subcollection[c("Source", "Target")],
                    f = list(subcollection$model_name, subcollection$data_name))
    variance <- do.call(rbind, lapply(1:length(groups),
                                      function(i)
                                      {
                                        x = groups[[i]]
                                        variance = var(x)
                                        name_split = strsplit(names(groups)[i], "\\.")[[1]]
                                        data.frame(model_name = name_split[1], data_name = name_split[2],
                                                   Source = variance[1,1], Target = variance[2,2],
                                                   ST = variance[1,2])
                                      }))
    # plot object
    g <- ggplot(subcollection, aes(x=Source, y=Target)) +
      geom_pointdensity(adjust=0.1) +
      geom_text(aes(x, y, label=lab),
                data=data.frame(x=Inf, y=0, lab=paste0("$\\begin{aligned}",
                                                       "\\boldsymbol{\\mu} &= \\begin{bmatrix} ",
                                                       paste0(
                                                         paste0(
                                                           formatC(
                                                             sapply(1:nrow(means),
                                                                    function(i){
                                                                      means[i,c("Source")]}),
                                                             digits=3, format="f"), " & "),
                                                         formatC(
                                                           sapply(1:nrow(means),
                                                                  function(i){
                                                                    means[i,c("Target")]}),
                                                           digits=3, format="f")),
                                                       " \\end{bmatrix} \\\\",
                                                       "\\boldsymbol{\\Sigma} &= \\begin{bmatrix} ",
                                                       paste0(
                                                         paste0(
                                                           formatC(
                                                             sapply(1:nrow(means),
                                                                    function(i){
                                                                      variance[i,c("Source")]}),
                                                             digits=3, format="f"), " & "),
                                                         paste0(
                                                           formatC(
                                                             sapply(1:nrow(means),
                                                                    function(i){
                                                                      variance[i,c("ST")]}),
                                                             digits=3, format="f"), " \\\\ "),
                                                         paste0(
                                                           formatC(
                                                             sapply(1:nrow(means),
                                                                    function(i){
                                                                      variance[i,c("ST")]}),
                                                             digits=3, format="f"), " & "),
                                                         formatC(
                                                           sapply(1:nrow(means),
                                                                  function(i){
                                                                    variance[i,c("Target")]}),
                                                           digits=3, format="f")),
                                                       " \\end{bmatrix}",
                                                       " \\end{aligned}$"),
                                model_name=means[c("model_name")],
                                data_name=means[c("data_name")]),
                hjust=1.1,vjust=-2,size=5) +
      theme_bw() +
      theme(text = element_text(size=25),
            strip.background = element_blank(),
            legend.key.height = unit(3, "cm"),
            strip.text = element_text(face="bold"),
            panel.grid = element_line(size = 1),
            axis.ticks.length=unit(.15, "cm"),
            legend.margin=margin(c(1,5,5,15))) +
      facet_grid(data_name ~ model_name) +
      scale_color_viridis(name="Density") +
      ylab(paste0("Target"," \\textit{",metric,"} [En]","\n")) +
      xlab(paste0("\n","Source"," \\textit{",metric,"} [De]"))
    if(!is.null(custom_breaks)){
      g <- g + scale_x_continuous(breaks = custom_breaks,
                                  labels = every_nth(custom_breaks, 5, inverse=TRUE))
      g <- g + scale_y_continuous(breaks = custom_breaks,
                                  labels = every_nth(custom_breaks, 5, inverse=TRUE))
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
  subcollection <- subset(collection, Type == metric)
  tikz(paste0(metric, ".tex"), width=15, height=10, standAlone = TRUE,
       packages =  paste0(getOption("tikzLatexPackages"),"\\usepackage{amsmath}\n"))
  g <- internal_plot(NULL)
  print(g)
  dev.off()
  texi2pdf(paste0(metric,".tex"),clean=TRUE)
  file.remove(paste0(metric,".tex"))
  file.rename(paste0(metric,".pdf"), paste0("./img/", metric, ".pdf"))
  unlink(paste0(metric,"*png"))
  # second plot with BLEU
  metric = "BLEU"
  custom_breaks <- seq(0, 100, 5)
  subcollection <- subset(collection, Type == metric)
  tikz(paste0(metric, ".tex"), width=15, height=10, standAlone = TRUE,
       packages =  paste0(getOption("tikzLatexPackages"),"\\usepackage{amsmath}\n"))
  g <- internal_plot(NULL)
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
