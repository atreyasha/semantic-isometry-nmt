#!/usr/bin/env Rscript
# -*- coding: utf-8 -*-

library(tools)
library(ggh4x)
library(rjson)
library(fields)
library(ggplot2)
library(tikzDevice)
library(optparse)
library(ggpointdensity)
library(gridExtra)

g_legend <- function(a.gplot){
  # source: https://stackoverflow.com/a/13650878
  # extract legend from custom ggplot object
  tmp <- ggplot_gtable(ggplot_build(a.gplot))
  leg <- which(sapply(tmp$grobs, function(x) x$name) == "guide-box")
  legend <- tmp$grobs[[leg]]
  return(legend)
}

post_process <- function(tex_file){
  # plots post-processing
  no_ext_name <- gsub("\\.tex", "", tex_file)
  pdf_file <- paste0(no_ext_name, ".pdf")
  texi2pdf(tex_file,clean=TRUE,
           texi2dvi=Sys.which("lualatex"))
  file.remove(tex_file)
  file.rename(pdf_file, paste0("./img/", pdf_file))
  unlink(paste0(no_ext_name, "*.png"))
  unlink("Rplots.pdf")
}

plot_shallow_metrics <- function(input_glob, return_early=FALSE){
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
                            name="Point\nDensity") +
      ylab(paste0("Target"," \\textit{",metric,"} [En]","\n")) +
      xlab(paste0("\n","Source"," \\textit{",metric,"} [De]"))
    return(g)
  }
  files <- Sys.glob(input_glob)
  if(length(files) != 4) stop("Number of json inputs not equal to 4")
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
    if (grepl("torch_hub", model_name)){
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
  if(return_early) return(collection)
  # first plot with chrf
  metric = "chrF"
  tex_file = paste0(tolower(metric), "_nmt.tex")
  subcollection <- subset(collection, Type == metric)
  g <- internal_plot()
  tikz(tex_file, width=15, height=10, standAlone = TRUE,
       packages = paste0(getOption("tikzLatexPackages"),"\\usepackage{amsmath}\n"), engine="luatex")
  print(g)
  dev.off()
  post_process(tex_file)
  # second plot with BLEU
  metric = "BLEU"
  tex_file = paste0(tolower(metric), "_nmt.tex")
  subcollection <- subset(collection, Type == metric)
  g <- internal_plot()
  tikz(tex_file, width=15, height=10, standAlone = TRUE,
       packages = paste0(getOption("tikzLatexPackages"),"\\usepackage{amsmath}\n"), engine="luatex")
  print(g)
  dev.off()
  post_process(tex_file)
}

plot_paraphrase_detector_outputs <- function(input_glob, return_early=FALSE) {
  files <- Sys.glob(input_glob)
  if(length(files) != 4) stop("Number of json inputs not equal to 4")
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
  long_collection <- collection
  xlmr_indices <- grep("roberta\\.base", names(long_collection))
  xlmr <- long_collection[xlmr_indices]
  xlmr["Type"] <- "XLM-R-Base"
  long_collection <- long_collection[-xlmr_indices]
  xlmr_large_indices <- grep("roberta\\.large", names(long_collection))
  xlmr_large <- long_collection[xlmr_large_indices]
  xlmr_large["Type"] <- "XLM-R-Large"
  long_collection <- long_collection[-xlmr_large_indices]
  long_collection["Type"] <- "Multilingual-BERT-Base"
  bert_indices <- grep("bert\\.base", names(long_collection))
  # rename columns
  names(long_collection)[grep("src",names(long_collection))] <- "Source"
  names(long_collection)[grep("translated",names(long_collection))] <- "Target"
  names(xlmr)[grep("src",names(xlmr))] <- "Source"
  names(xlmr)[grep("translated",names(xlmr))] <- "Target"
  names(xlmr_large)[grep("src",names(xlmr_large))] <- "Source"
  names(xlmr_large)[grep("translated",names(xlmr_large))] <- "Target"
  # rbind everything together
  tmp_collection <- rbind(long_collection[-(which(names(long_collection)
                                             %in% c("model_name","data_name")))],
                           xlmr, xlmr_large)
  long_collection <- cbind(long_collection[c("model_name", "data_name")], tmp_collection)
  # make rounding analysis
  rounded <- as.data.frame(lapply(collection, function(x)
  {
    if(is.numeric(x)) round(x) else x
  }))
  bert_indices <- grep("bert\\.base", names(collection))
  xlmr_indices <- grep("roberta\\.base", names(collection))
  xlmr_large_indices <- grep("roberta\\.large", names(collection))
  bert <- as.factor(paste0("(",rounded[,bert_indices[1]],
                          ",",rounded[,bert_indices[2]],")"))
  xlmr <- as.factor(paste0("(",rounded[,xlmr_indices[1]],
                          ",",rounded[,xlmr_indices[2]],")"))
  xlmr_large <- as.factor(paste0("(",rounded[,xlmr_large_indices[1]],
                                ",",rounded[,xlmr_large_indices[2]],")"))
  compressed_collection <- cbind(bert,xlmr,xlmr_large)
  compressed_collection <- lapply(1:nrow(compressed_collection), function(i)
  {
    x <- as.numeric(compressed_collection[i,])
    if(length(unique(x)) == length(x)){
      c(0,"No Agreement")
    } else {
      if(length(unique(x)) == 1){
        c(as.numeric(names(which.max(table(x)))), "Full Agreement")
      } else {
        number <- as.numeric(names(which.max(table(x))))
        indices <- as.numeric(which(x == number))
        if(all(indices == c(1,2))) {
          c(number, "Majority Agreement: \\{BERT $\\cap$ XLM-R$_{B}\\}$")
        } else if(all(indices == c(2,3))) {
          c(number, "Majority Agreement: \\{XLM-R$_{B}$ $\\cap$ XLM-R$_{L}\\}$")
        } else if(all(indices == c(1,3))) {
          c(number, "Majority Agreement: \\{BERT $\\cap$ XLM-R$_{L}\\}$")
        }
      }
    }
  })
  compressed_collection <- do.call(rbind, compressed_collection)
  compressed_collection <- cbind(collection[,c("model_name","data_name")],
                                 compressed_collection)
  names(compressed_collection)[which(names(compressed_collection)
                                     %in% c("1","2"))] <- c("Label","Type")
  compressed_collection[,"Label"] <- as.factor(compressed_collection[,"Label"])
  repeated_string = "$\\big\\{P_{st}^{i}\\big\\}_{i}^{n} = "
  levels(compressed_collection$Label) <- paste0(repeated_string, c("\\emptyset$",
                                                                   "[0,0]$",
                                                                   "[0,1]$",
                                                                   "[1,0]$",
                                                                   "[1,1]$"))
  # stop here if necessary and return everything
  if(return_early) return(list(long_collection, compressed_collection))
  # make dummy plot
  dummy <- data.frame(x = seq(0,1,0.01), y = seq(0,1,0.01))
  q <- ggplot(data=dummy, aes(x=x, y=y)) + geom_point(aes(color=x)) +
    scale_color_gradientn(colors = tim.colors(100),
                          name="Normalized Contour Density") +
    theme(legend.position = "bottom",
          legend.box="horizontal",
          legend.key.width = unit(5, "cm"),
          text = element_text(size=18)) +
    guides(colour = guide_colourbar(title.position="left", title.hjust = 0.5,
                                    title.vjust = 0.9))
  # get legend of dummy plot
  mylegend<-g_legend(q)
  # make full plot
  g <- ggplot(data=long_collection, aes(x=Source, y=Target)) +
    geom_density_2d_filled(contour_var = "ndensity", binwidth=0.01) +
    scale_fill_manual(values = tim.colors(100),
                      name="Density") +
    facet_nested(data_name ~ model_name + Type) +
    coord_cartesian(expand = FALSE) +
    xlab("\nSource Paraphrase Softmax Score [De]") +
    ylab("Target Paraphrase Softmax Score [En]\n") +
    theme_bw() +
    theme(text = element_text(size=18),
          strip.background = element_blank(),
          ## legend.key.height = unit(0.01, "cm"),
          legend.position = "none",
          strip.text = element_text(face="bold"),
          panel.grid = element_line(size = 1),
          axis.ticks.length=unit(.15, "cm"),
          legend.margin=margin(c(1,5,5,15)))
  tex_file = "paraphrase_detection_softmax_all.tex"
  tikz(tex_file, width=20, height=8,
       standAlone = TRUE, engine="luatex")
  print(grid.arrange(g, mylegend, nrow=2,heights=c(10, 1)))
  dev.off()
  post_process(tex_file)
  # make compressed plot
  g <- ggplot(compressed_collection, aes(x=Label, fill=Type)) +
    geom_bar(color="black", size = 0.5, alpha = 0.75, width = 0.75) +
    theme_bw() +
    theme(text = element_text(size=18),
          strip.background = element_blank(),
          ## legend.key.height = unit(0.01, "cm"),
          legend.position = "bottom",
          legend.title = element_blank(),
          strip.text = element_text(face="bold"),
          panel.grid = element_line(size = 1),
          axis.text.x = element_text(vjust=-1.5, size=14),
          axis.title.x = element_text(vjust=-1.5),
          axis.ticks.length=unit(.15, "cm"),
          legend.margin=margin(c(10,5,5,1))
          ) +
    scale_fill_brewer(palette = "RdYlBu") +
    facet_grid(data_name ~ model_name) +
    xlab("\nJoint Prediction Decision") +
    ylab("Prediction Count\n")
  tex_file = "paraphrase_detection_joint_decision.tex"
  tikz(tex_file, width=18, height=10, standAlone = TRUE, engine="luatex")
  print(g)
  dev.off()
  post_process(tex_file)
}

plot_shallow_deep_correlations <- function(input_glob) {
  shallow <- subset(plot_shallow_metrics(input_glob, return_early = TRUE),
                    Type=="chrF")
  deep <- plot_paraphrase_detector_outputs(input_glob, return_early = TRUE)
  deep_all <- deep[[1]]
  deep_compressed <- deep[[2]]
  # extract paraphrase detection scores and convert them to factors
  rounded <- sapply(deep_all[c("Source","Target")], round)
  discrete <- as.factor(paste0("$P_{st} = [",apply(rounded,1,paste,collapse=","),"]$"))
  deep_all <- deep_all[-which(names(deep_all) %in% c("Source","Target"))]
  deep_all["Discrete"] <- discrete
  collection <- cbind(deep_all, shallow[c("Source","Target")])
  # plot all results
  tex_file = "chrf_paraphrase_detection_all.tex"
  g <- ggplot(collection, aes(x = Source, y = Target)) +
    geom_pointdensity(aes(x = Source, y = Target), adjust=0.1) +
    theme_bw() +
    theme(text = element_text(size=18),
          strip.background = element_blank(),
          legend.position = "bottom",
          legend.key.width = unit(6, "cm"),
          strip.text = element_text(face="bold"),
          panel.grid = element_line(size = 1),
          axis.ticks.length = unit(.125, "cm"),
          plot.title = element_text(hjust=0.5),
          axis.text = element_text(size=13),
          ## axis.text.x = element_text(angle=45, vjust=0.6)
          ) +
    scale_color_gradientn(colours = tim.colors(24),
                          name="Point Density") +
    scale_x_continuous(breaks = c(0.25,0.50,0.75)) +
    scale_y_continuous(breaks = c(0.25,0.50,0.75)) +
    facet_nested(model_name+data_name ~ Type+Discrete) +
    guides(colour = guide_colourbar(title.position="left", title.hjust = 0.5,
                                    title.vjust = 0.9)) +
    ylab(paste0("Target"," \\textit{chrF} [En]","\n")) +
    xlab(paste0("\n","Source"," \\textit{chrF} [De]"))
  # print to file
  tikz(tex_file, width=26, height=11, standAlone = TRUE, engine="luatex")
  print(grid.arrange(g))
  dev.off()
  post_process(tex_file)
  # plot compressed results
  shallow <- shallow[-c(which(names(shallow) == "Type"))]
  collection <- cbind(shallow, deep_compressed[-c(which(names(deep_compressed)
                                                        %in% c("model_name", "data_name")))])
  tex_file = "chrf_paraphrase_detection_joint_decision.tex"
  g <- ggplot(collection, aes(x = Source, y = Target)) +
    geom_pointdensity(aes(x = Source, y = Target), adjust=0.1) +
    theme_bw() +
    theme(text = element_text(size=18),
          strip.background = element_blank(),
          strip.text.x = element_text(margin = margin(0.1,0,0.34,0, "cm")),
          legend.position = "bottom",
          legend.key.width = unit(6, "cm"),
          strip.text = element_text(face="bold"),
          panel.grid = element_line(size = 1),
          axis.ticks.length = unit(.125, "cm"),
          plot.title = element_text(hjust=0.5),
          axis.text = element_text(size=13),
          ## axis.text.x = element_text(angle=45, vjust=0.6)
          ) +
    facet_nested(data_name ~ model_name+Label) +
    scale_color_gradientn(colours = tim.colors(24),
                          name="Point Density") +
    scale_x_continuous(breaks = c(0.25,0.50,0.75)) +
    scale_y_continuous(breaks = c(0.25,0.50,0.75)) +
    guides(colour = guide_colourbar(title.position="left", title.hjust = 0.5,
                                    title.vjust = 0.9)) +
    ylab(paste0("Target"," \\textit{chrF} [En]","\n")) +
    xlab(paste0("\n","Source"," \\textit{chrF} [De]"))
  tikz(tex_file, width=20, height=7, standAlone = TRUE, engine="luatex")
  print(grid.arrange(g))
  dev.off()
  post_process(tex_file)
}

# parse command-line arguments
parser <- OptionParser()
parser <- add_option(parser, c("-s", "--shallow-metrics"), action="store_true",
                     default=FALSE,
                     help="Flag for plotting shallow metrics [default: %default]")
parser <- add_option(parser, c("-p", "--paraphrase-detector-outputs"),
                     action="store_true", default=FALSE,
                     help="Flag for plotting paraphrase detector outputs [default: %default]")
parser <- add_option(parser, c("-m", "--mixed"),
                     action="store_true", default=FALSE,
                     help="Flag for plotting a mix of shallow and deep metrics [default: %default]")
parser <- add_option(parser, c("-j", "--json-glob"),
                     type="character",
                     default="./predictions/*/*.json",
                     help="Glob for finding input jsons [default: %default]")
args <- parse_args(parser)
if(args$s){
  plot_shallow_metrics(args$j)
} else if(args$p){
  plot_paraphrase_detector_outputs(args$j)
} else if(args$m){
  plot_shallow_deep_correlations(args$j)
}
