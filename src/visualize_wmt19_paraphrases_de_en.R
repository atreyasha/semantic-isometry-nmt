#!/usr/bin/env Rscript
# -*- coding: utf-8 -*-

library(tools)
library(rjson)
library(fields)
library(ggplot2)
library(tikzDevice)
library(optparse)
library(ggpointdensity)
library(gridExtra)

g_legend<-function(a.gplot){
  # source: https://stackoverflow.com/a/13650878
  # extract legend from custom ggplot object
  tmp <- ggplot_gtable(ggplot_build(a.gplot))
  leg <- which(sapply(tmp$grobs, function(x) x$name) == "guide-box")
  legend <- tmp$grobs[[leg]]
  return(legend)
}

plot_shallow_metrics <- function(input_glob){
  # internal re-usable plot function
  internal_plot <- function(){
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
      ## scale_color_viridis(name="Density") +
      scale_color_gradientn(colours = tim.colors(24),
                            name="Density") +
      ylab(paste0("Target"," \\textit{",metric,"} [En]","\n")) +
      xlab(paste0("\n","Source"," \\textit{",metric,"} [De]"))
    return(g)
  }
  files <- Sys.glob(input_glob)
  collection <- lapply(1:length(files), function(i){
    data <- fromJSON(file = files[i])
    data_name = basename(files[i])
    model_name = basename(dirname(files[i]))
    filtered <- data.frame(do.call(rbind, lapply(data, function(x) {
      unlist(x[c("chrf_src","chrf_translated", "bleu_src",
                 "bleu_translated")])})))
    if (grepl("ar", data_name)) {
      data_name <- "WMT19 Test AR"
    }
    else {
      data_name <- "WMT19 Test Legacy"
    }
    if (grepl("hub", model_name)){
      model_name <- "FAIR WMT19 Transformer"
    }
    else {
      model_name <- "Scaling NMT WMT16 Transformer"
    }
    filtered <- cbind(model_name, data_name, filtered)
    return(filtered)
  })
  collection <- do.call(rbind, collection)
  hold_out <- collection[-(which(names(collection) %in% c("chrf_src","chrf_translated")))]
  collection <- collection[-(which(names(collection) %in% c("bleu_src","bleu_translated")))]
  names(collection)[which(names(collection) %in% c("chrf_src","chrf_translated"))] <- c("Source", "Target")
  collection["Type"] <- "chrF"
  names(hold_out)[which(names(hold_out) %in% c("bleu_src","bleu_translated"))] <- c("Source", "Target")
  hold_out["Type"] <- "BLEU"
  collection <- rbind(collection, hold_out)
  # first plot with chrf
  metric = "chrF"
  subcollection <- subset(collection, Type == metric)
  g <- internal_plot()
  tikz(paste0(metric, ".tex"), width=15, height=10, standAlone = TRUE,
       packages =  paste0(getOption("tikzLatexPackages"),"\\usepackage{amsmath}\n"), engine="luatex")
  print(g)
  dev.off()
  texi2pdf(paste0(metric,".tex"),clean=TRUE,texi2dvi=Sys.which("lualatex"))
  file.remove(paste0(metric,".tex"))
  file.rename(paste0(metric,".pdf"), paste0("./img/", metric, ".pdf"))
  unlink(paste0(metric,"*png"))
  # second plot with BLEU
  metric = "BLEU"
  subcollection <- subset(collection, Type == metric)
  g <- internal_plot()
  tikz(paste0(metric, ".tex"), width=15, height=10, standAlone = TRUE,
       packages =  paste0(getOption("tikzLatexPackages"),"\\usepackage{amsmath}\n"), engine="luatex")
  print(g)
  dev.off()
  texi2pdf(paste0(metric,".tex"),clean=TRUE,texi2dvi=Sys.which("lualatex"))
  file.remove(paste0(metric,".tex"))
  file.rename(paste0(metric,".pdf"), paste0("./img/", metric, ".pdf"))
  unlink(paste0(metric,"*png"))
}

plot_paraphrase_detector_outputs <- function(input_glob) {
  files <- Sys.glob(input_glob)
  collection <- lapply(1:length(files), function(i){
    data <- fromJSON(file = files[i])
    data_name = basename(files[i])
    model_name = basename(dirname(files[i]))
    indices <- grep("(bert|xlm)", names(data[[1]]))
    filtered <- data.frame(do.call(rbind, lapply(data, function(x) {
      unlist(x[indices])})))
    if (grepl("ar", data_name)) {
      data_name <- "WMT19 Test AR"
    }
    else {
      data_name <- "WMT19 Test Legacy"
    }
    if (grepl("hub", model_name)){
      model_name <- "FAIR WMT19 Transformer"
    }
    else {
      model_name <- "Scaling NMT WMT16 Transformer"
    }
    filtered <- cbind(model_name, data_name, filtered)
    return(filtered)
  })
  collection <- do.call(rbind, collection)
  # split up data
  xlmr_indices <- grep("roberta\\.base", names(collection))
  xlmr <- collection[xlmr_indices]
  xlmr["Type"] <- "XLM-R-Base"
  collection <- collection[-xlmr_indices]
  xlmr_large_indices <- grep("roberta\\.large", names(collection))
  xlmr_large <- collection[xlmr_large_indices]
  xlmr_large["Type"] <- "XLM-R-Large"
  collection <- collection[-xlmr_large_indices]
  collection["Type"] <- "Multilingual-BERT-Base"
  bert_indices <- grep("bert\\.base", names(collection))
  # rename columns
  names(collection)[grep("src",names(collection))] <- "Source"
  names(collection)[grep("translated",names(collection))] <- "Target"
  names(xlmr)[grep("src",names(xlmr))] <- "Source"
  names(xlmr)[grep("translated",names(xlmr))] <- "Target"
  names(xlmr_large)[grep("src",names(xlmr_large))] <- "Source"
  names(xlmr_large)[grep("translated",names(xlmr_large))] <- "Target"
  # rbind everything together
  new_collection <- rbind(collection[-(which(names(collection)
                                             %in% c("model_name","data_name")))], xlmr, xlmr_large)
  collection <- cbind(collection[c("model_name", "data_name")], new_collection)
  # make dummy plot
  dummy <- data.frame(x = seq(0,1,0.01), y = seq(0,1,0.01))
  q <- ggplot(data=dummy, aes(x=x, y=y)) + geom_point(aes(color=x)) +
    scale_color_gradientn(colors = tim.colors(100),
                          name="Normalized Density") +
    theme(legend.position = "bottom",
          legend.box="horizontal",
          legend.key.width = unit(5, "cm"),
          text = element_text(size=14)) +
    guides(colour = guide_colourbar(title.position="left", title.hjust = 0.5,
                                    title.vjust = 0.8))
  # get legend of dummy plot
  mylegend<-g_legend(q)
  # make actual plot
  g <- ggplot(data=collection, aes(x=Source, y=Target)) +
    geom_density_2d_filled(contour_var = "ndensity", binwidth=0.01) +
    scale_fill_manual(values = tim.colors(100),
                      name="Density") +
    facet_grid(data_name ~ model_name + Type) +
    coord_cartesian(expand = FALSE) +
    xlab("\nSource Paraphrase Softmax Score [De]") +
    ylab("Target Paraphrase Softmax Score [En]\n") +
    theme_bw() +
    theme(text = element_text(size=14),
          strip.background = element_blank(),
          ## legend.key.height = unit(0.01, "cm"),
          legend.position = "none",
          strip.text = element_text(face="bold"),
          panel.grid = element_line(size = 1),
          axis.ticks.length=unit(.15, "cm"),
          legend.margin=margin(c(1,5,5,15)))
  tikz(paste0("paraphrase_detection_results.tex"), width=20, height=8,
       standAlone = TRUE, engine="luatex")
  grid.arrange(g, mylegend, nrow=2,heights=c(10, 1))
  dev.off()
  texi2pdf("paraphrase_detection_results.tex",clean=TRUE,
           texi2dvi=Sys.which("lualatex"))
  file.remove("paraphrase_detection_results.tex")
  file.rename("paraphrase_detection_results.pdf",
              "./img/paraphrase_detection_results.pdf")
  unlink("paraphrase_detection_results*.png")
  unlink("Rplots.pdf")
}

# parse command-line arguments
parser <- OptionParser()
parser <- add_option(parser, c("-s", "--shallow-metrics"), action="store_true",
                     default=FALSE,
                     help="Flag for plotting shallow metrics")
parser <- add_option(parser, c("-p", "--paraphrase-detector-outputs"),
                     action="store_true", default=FALSE,
                     help="Flag for plotting paraphrase detector outputs")
parser <- add_option(parser, c("-j", "--json-glob"),
                     type="character",
                     default="./predictions/*/*.json",
                     help="Glob for finding input jsons [default: %default]")
args <- parse_args(parser)
if(args$s){
  plot_shallow_metrics(args$j)
} else if(args$p){
  plot_paraphrase_detector_outputs(args$j)
}
