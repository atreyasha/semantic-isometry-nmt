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
library(reshape2)

g_legend <- function(a.gplot) {
  # source: https://stackoverflow.com/a/13650878
  # extract legend from custom ggplot object
  tmp <- ggplot_gtable(ggplot_build(a.gplot))
  leg <- which(sapply(tmp$grobs, function(x) x$name) == "guide-box")
  legend <- tmp$grobs[[leg]]
  return(legend)
}

post_process <- function(tex_file) {
  # plots post-processing
  no_ext_name <- gsub("\\.tex", "", tex_file)
  pdf_file <- paste0(no_ext_name, ".pdf")
  texi2pdf(tex_file,
    clean = TRUE,
    texi2dvi = Sys.which("lualatex")
  )
  file.remove(tex_file)
  file.rename(pdf_file, paste0("./img/", pdf_file))
  unlink(paste0(no_ext_name, "*.png"))
  unlink("Rplots.pdf")
}

# source: https://stackoverflow.com/a/45614547
GeomSplitViolin <- ggproto("GeomSplitViolin", GeomViolin,
  draw_group = function(self, data, ..., draw_quantiles = NULL) {
    data <- transform(data, xminv = x - violinwidth * (x - xmin), xmaxv = x + violinwidth * (xmax - x))
    grp <- data[1, "group"]
    newdata <- plyr::arrange(transform(data, x = if (grp %% 2 == 1) xminv else xmaxv), if (grp %% 2 == 1) y else -y)
    newdata <- rbind(newdata[1, ], newdata, newdata[nrow(newdata), ], newdata[1, ])
    newdata[c(1, nrow(newdata) - 1, nrow(newdata)), "x"] <- round(newdata[1, "x"])
    if (length(draw_quantiles) > 0 & !scales::zero_range(range(data$y))) {
      stopifnot(all(draw_quantiles >= 0), all(draw_quantiles <=
        1))
      quantiles <- ggplot2:::create_quantile_segment_frame(data, draw_quantiles)
      aesthetics <- data[rep(1, nrow(quantiles)), setdiff(names(data), c("x", "y")), drop = FALSE]
      aesthetics$alpha <- rep(1, nrow(quantiles))
      both <- cbind(quantiles, aesthetics)
      quantile_grob <- GeomPath$draw_panel(both, ...)
      ggplot2:::ggname("geom_split_violin", grid::grobTree(GeomPolygon$draw_panel(newdata, ...), quantile_grob))
    }
    else {
      ggplot2:::ggname("geom_split_violin", GeomPolygon$draw_panel(newdata, ...))
    }
  }
)

# source: https://stackoverflow.com/a/45614547
geom_split_violin <- function(mapping = NULL, data = NULL, stat = "ydensity", position = "identity", ...,
                              draw_quantiles = NULL, trim = TRUE, scale = "area", na.rm = FALSE,
                              show.legend = NA, inherit.aes = TRUE) {
  layer(
    data = data, mapping = mapping, stat = stat, geom = GeomSplitViolin,
    position = position, show.legend = show.legend, inherit.aes = inherit.aes,
    params = list(trim = trim, scale = scale, draw_quantiles = draw_quantiles, na.rm = na.rm, ...)
  )
}


plot_shallow_metrics <- function(input_glob, return_early = FALSE) {
  # internal re-usable plot function
  internal_plot <- function() {
    # compute summary statistics
    means <- aggregate(subcollection[c("Source", "Target")],
      by = subcollection[c("model_name", "data_name")], FUN = mean
    )
    groups <- split(subcollection[c("Source", "Target")],
      f = list(subcollection$model_name, subcollection$data_name)
    )
    variance <- do.call(rbind, lapply(
      1:length(groups),
      function(i) {
        x <- groups[[i]]
        variance <- var(x)
        name_split <- strsplit(names(groups)[i], "\\.")[[1]]
        data.frame(
          model_name = name_split[1], data_name = name_split[2],
          Source = variance[1, 1], Target = variance[2, 2],
          ST = variance[1, 2]
        )
      }
    ))
    # plot object
    g <- ggplot(subcollection, aes(x = Source, y = Target)) +
      geom_pointdensity(adjust = 0.1) +
      theme_bw() +
      theme(
        text = element_text(size = 27),
        strip.background = element_blank(),
        ## legend.key.height = unit(3, "cm"),
        legend.key.width = unit(5, "cm"),
        legend.position = "bottom",
        strip.text = element_text(face = "bold"),
        panel.grid = element_line(size = 1),
        axis.ticks.length = unit(.15, "cm"),
        legend.margin = margin(c(1, 5, 5, 15)),
        axis.title.x = element_text(margin = margin(t = 20, r = 0, b = 0, l = 0)),
        axis.title.y = element_text(margin = margin(t = 0, r = 20, b = 0, l = 5))
      ) +
      facet_nested(~ model_name + data_name) +
      ## scale_color_viridis(name="Density") +
      scale_color_gradientn(
        colours = tim.colors(24),
        name = "Point Density"
      ) +
      guides(colour = guide_colourbar(
        title.position = "left", title.hjust = 0.5,
        title.vjust = 1.1
      )) +
      scale_x_continuous(breaks = c(0.25, 0.50, 0.75)) +
      ylab(paste0("Target ", metric, " [en]")) +
      xlab(paste0("Source ", metric, " [de]"))
    return(g)
  }
  files <- Sys.glob(input_glob)
  if (length(files) != 4) stop("Number of json inputs not equal to 4")
  collection <- lapply(1:length(files), function(i) {
    data <- fromJSON(file = files[i])
    data_name <- basename(files[i])
    model_name <- basename(dirname(files[i]))
    filtered <- data.frame(do.call(rbind, lapply(data, function(x) {
      unlist(x[c(
        "chrf_src", "chrf_translated", "bleu_src",
        "bleu_translated"
      )])
    })))
    if (grepl("ar", data_name)) {
      data_name <- "WMT19 AR"
    }
    else {
      data_name <- "WMT19 Legacy"
    }
    if (grepl("torch_hub", model_name)) {
      model_name <- "FAIR WMT19 Transformer"
    }
    else {
      model_name <- "Scaling NMT WMT16 Transformer"
    }
    filtered <- cbind(model_name, data_name, filtered)
    return(filtered)
  })
  collection <- do.call(rbind, collection)
  hold_out <- collection[-(which(names(collection) %in% c("chrf_src", "chrf_translated")))]
  collection <- collection[-(which(names(collection) %in% c("bleu_src", "bleu_translated")))]
  names(collection)[which(names(collection) %in% c("chrf_src", "chrf_translated"))] <- c("Source", "Target")
  collection["Type"] <- "$\\overline{\\text{chrF}_2}$"
  names(hold_out)[which(names(hold_out) %in% c("bleu_src", "bleu_translated"))] <- c("Source", "Target")
  hold_out["Type"] <- "$\\overline{\\text{BLEU}}$"
  collection <- rbind(collection, hold_out)
  if (return_early) {
    return(collection)
  }
  # first plot with chrf
  metric <- "$\\overline{\\text{chrF}_2}$"
  tex_file <- "chrf_nmt.tex"
  subcollection <- subset(collection, Type == metric)
  g <- internal_plot()
  tikz(tex_file,
    width = 20, height = 7.5, standAlone = TRUE,
    packages = paste0(getOption("tikzLatexPackages"), "\\usepackage{amsmath}\n"), engine = "luatex"
  )
  print(g)
  dev.off()
  post_process(tex_file)
}

plot_paraphrase_detector_outputs <- function(input_glob, return_early = FALSE) {
  files <- Sys.glob(input_glob)
  if (length(files) != 4) stop("Number of json inputs not equal to 4")
  collection <- lapply(1:length(files), function(i) {
    data <- fromJSON(file = files[i])
    data_name <- basename(files[i])
    model_name <- basename(dirname(files[i]))
    indices <- grep("(bert|xlm)", names(data[[1]]))
    filtered <- data.frame(do.call(rbind, lapply(data, function(x) {
      unlist(x[indices])
    })))
    if (grepl("ar", data_name)) {
      data_name <- "WMT19 AR"
    }
    else {
      data_name <- "WMT19 Legacy"
    }
    if (grepl("hub", model_name)) {
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
  xlmr["Type"] <- "XLM-R\\textsubscript{Base}"
  long_collection <- long_collection[-xlmr_indices]
  xlmr_large_indices <- grep("roberta\\.large", names(long_collection))
  xlmr_large <- long_collection[xlmr_large_indices]
  xlmr_large["Type"] <- "XLM-R\\textsubscript{Large}"
  long_collection <- long_collection[-xlmr_large_indices]
  long_collection["Type"] <- "mBERT\\textsubscript{Base}"
  bert_indices <- grep("bert\\.base", names(long_collection))
  # rename columns
  names(long_collection)[grep("src", names(long_collection))] <- "Source"
  names(long_collection)[grep("translated", names(long_collection))] <- "Target"
  names(xlmr)[grep("src", names(xlmr))] <- "Source"
  names(xlmr)[grep("translated", names(xlmr))] <- "Target"
  names(xlmr_large)[grep("src", names(xlmr_large))] <- "Source"
  names(xlmr_large)[grep("translated", names(xlmr_large))] <- "Target"
  # rbind everything together
  tmp_collection <- rbind(
    long_collection[-(which(names(long_collection)
    %in% c("model_name", "data_name")))],
    xlmr, xlmr_large
  )
  long_collection <- cbind(long_collection[c("model_name", "data_name")], tmp_collection)
  # make rounding analysis
  rounded <- as.data.frame(lapply(collection, function(x) {
    if (is.numeric(x)) round(x) else x
  }))
  bert_indices <- grep("bert\\.base", names(collection))
  xlmr_indices <- grep("roberta\\.base", names(collection))
  xlmr_large_indices <- grep("roberta\\.large", names(collection))
  bert <- as.factor(paste0(
    "(", rounded[, bert_indices[1]],
    ",", rounded[, bert_indices[2]], ")"
  ))
  xlmr <- as.factor(paste0(
    "(", rounded[, xlmr_indices[1]],
    ",", rounded[, xlmr_indices[2]], ")"
  ))
  xlmr_large <- as.factor(paste0(
    "(", rounded[, xlmr_large_indices[1]],
    ",", rounded[, xlmr_large_indices[2]], ")"
  ))
  compressed_collection <- cbind(bert, xlmr, xlmr_large)
  compressed_collection <- lapply(1:nrow(compressed_collection), function(i) {
    x <- as.numeric(compressed_collection[i, ])
    if (length(unique(x)) == length(x)) {
      c(0, "No Agreement")
    } else {
      if (length(unique(x)) == 1) {
        c(as.numeric(names(which.max(table(x)))), "Full Agreement")
      } else {
        number <- as.numeric(names(which.max(table(x))))
        indices <- as.numeric(which(x == number))
        if (all(indices == c(1, 2))) {
          c(number, "Majority: \\{mBERT\\textsubscript{Base} $\\cap$ XLM-R\\textsubscript{Base}\\}")
        } else if (all(indices == c(2, 3))) {
          c(number, "Majority: \\{XLM-R\\textsubscript{Base} $\\cap$ XLM-R\\textsubscript{Large}\\}")
        } else if (all(indices == c(1, 3))) {
          c(number, "Majority: \\{mBERT\\textsubscript{Base} $\\cap$ XLM-R\\textsubscript{Large}\\}")
        }
      }
    }
  })
  compressed_collection <- do.call(rbind, compressed_collection)
  compressed_collection <- cbind(
    collection[, c("model_name", "data_name")],
    compressed_collection
  )
  names(compressed_collection)[which(names(compressed_collection)
  %in% c("1", "2"))] <- c("Label", "Type")
  compressed_collection[, "Label"] <- as.factor(compressed_collection[, "Label"])
  levels(compressed_collection$Label) <- paste0(
    "$\\mathbf{M(S_{XY}^{\\mathsf{T}})}=",
    c(
      "\\emptyset$",
      "[0,0]$",
      "[0,1]$",
      "[1,0]$",
      "[1,1]$"
    )
  )
  # stop here if necessary and return everything
  if (return_early) {
    return(list(long_collection, compressed_collection))
  }
  levels(compressed_collection$Label) <- paste0("$", c(
    "\\emptyset$",
    "[0,0]$",
    "[0,1]$",
    "[1,0]$",
    "[1,1]$"
  ))
  # make dummy plot
  dummy <- data.frame(x = seq(0, 1, 0.01), y = seq(0, 1, 0.01))
  q <- ggplot(data = dummy, aes(x = x, y = y)) +
    geom_point(aes(color = x)) +
    scale_color_gradientn(
      colors = tim.colors(100),
      name = "Normalized Contour Density"
    ) +
    theme(
      legend.position = "bottom",
      legend.box = "horizontal",
      legend.key.width = unit(5, "cm"),
      text = element_text(size = 27)
    ) +
    guides(colour = guide_colourbar(
      title.position = "left", title.hjust = 0.5,
      title.vjust = 1.1
    ))
  # get legend of dummy plot
  mylegend <- g_legend(q)
  # make full plot
  g <- ggplot(data = long_collection, aes(x = Source, y = Target)) +
    geom_density_2d_filled(contour_var = "ndensity", binwidth = 0.01) +
    scale_fill_manual(
      values = tim.colors(100),
      name = "Density"
    ) +
    facet_nested(data_name ~ model_name + Type) +
    coord_cartesian(expand = FALSE) +
    xlab("Source Paraphrase Softmax Score [de]") +
    ylab("Target Paraphrase Softmax Score [en]") +
    theme_bw() +
    theme(
      text = element_text(size = 27),
      strip.background = element_blank(),
      ## legend.key.height = unit(0.01, "cm"),
      legend.position = "none",
      strip.text = element_text(face = "bold"),
      panel.grid = element_line(size = 1),
      axis.ticks.length = unit(.15, "cm"),
      legend.margin = margin(c(1, 5, 5, 15)),
      axis.title.x = element_text(margin = margin(t = 10, r = 0, b = 5, l = 0)),
      axis.title.y = element_text(margin = margin(t = 0, r = 10, b = 0, l = 0))
    )
  tex_file <- "paraphrase_detection_softmax_all.tex"
  tikz(tex_file,
    width = 20, height = 8,
    standAlone = TRUE, engine = "luatex"
  )
  print(grid.arrange(g, mylegend, nrow = 2, heights = c(10, 1)))
  dev.off()
  post_process(tex_file)
  # make compressed plot
  g <- ggplot(compressed_collection, aes(x = Label, fill = Type)) +
    geom_bar(color = "black", size = 0.5, alpha = 0.75, width = 0.70) +
    theme_bw() +
    theme(
      text = element_text(size = 27),
      strip.background = element_blank(),
      legend.key.width = unit(0.65, "cm"),
      legend.spacing.y = unit(0.2, "cm"),
      legend.position = "bottom",
      legend.title = element_blank(),
      strip.text = element_text(face = "bold"),
      panel.grid = element_line(size = 1),
      axis.text.x = element_text(vjust = -1.5, size = 22),
      axis.ticks.length = unit(.15, "cm"),
      legend.margin = margin(c(10, 5, 5, 1)),
      axis.title.x = element_text(
        margin = margin(t = 20, r = 0, b = 20, l = 0),
        vjust = -1.5
      ),
      axis.title.y = element_text(margin = margin(t = 0, r = 15, b = 0, l = 0))
    ) +
    scale_fill_brewer(palette = "RdYlBu") +
    guides(fill = guide_legend(nrow = 2, byrow = TRUE)) +
    facet_grid(data_name ~ model_name) +
    xlab("$\\mathbf{M(S_{XY}^{\\mathsf{T}})}$") +
    ylab("Prediction Count")
  tex_file <- "paraphrase_detection_joint_decision.tex"
  tikz(tex_file, width = 18.5, height = 9, standAlone = TRUE, engine = "luatex")
  print(g)
  dev.off()
  post_process(tex_file)
}

plot_shallow_deep_correlations <- function(input_glob) {
  shallow <- subset(
    plot_shallow_metrics(input_glob, return_early = TRUE),
    Type == "$\\overline{\\text{chrF}_2}$"
  )
  deep <- plot_paraphrase_detector_outputs(input_glob, return_early = TRUE)
  deep_all <- deep[[1]]
  deep_compressed <- deep[[2]]
  rounded <- sapply(deep_all[c("Source", "Target")], round)
  discrete <- as.factor(paste0(
    "$\\mathbf{S_{XY}^{\\mathsf{T}}} = [",
    apply(rounded, 1, paste, collapse = ","), "]$"
  ))
  deep_all <- deep_all[-which(names(deep_all) %in% c("Source", "Target"))]
  deep_all["Discrete"] <- discrete
  # first collection variant
  collection <- cbind(rounded, shallow)
  names(collection)[c(1, 2)] <- c("label", "label")
  collection_1 <- collection[c(1, 3, 4, 5, 7)]
  collection_2 <- collection[c(2, 3, 4, 6, 7)]
  collection <- rbind(
    melt(collection_1, measure.vars = "Source"),
    melt(collection_2, measure.vars = "Target")
  )
  collection$label <- as.factor(collection$label)
  # plot object
  g <- ggplot(collection, aes(x = label, y = value, fill = variable)) +
    geom_split_violin(width = 0.7, alpha = 0.8, size = 1, color = "black") +
    geom_boxplot(
      width = 0.1, fill = "white", size = 1,
      outlier.shape = 1, outlier.size = 2.5
    ) +
    geom_text(aes(x, y, label = lab),
      data = data.frame(
        x = 1.5, y = 0.93, lab = "$\\begin{gathered} r>0 \\\\ *** \\end{gathered}$",
        variable = levels(collection$variable)
      ), size = 7
    ) +
    theme_bw() +
    theme(
      text = element_text(size = 27),
      strip.background = element_blank(),
      legend.key.width = unit(0.8, "cm"),
      legend.spacing.y = unit(0.2, "cm"),
      legend.title = element_blank(),
      legend.position = "bottom",
      strip.text = element_text(face = "bold"),
      panel.grid = element_line(size = 1),
      axis.ticks.length = unit(.15, "cm"),
      axis.title.y = element_text(margin = margin(t = 0, r = 15, b = 0, l = 10))
    ) +
    scale_fill_brewer(palette = "Set1", direction = -1) +
    facet_nested(. ~ model_name + data_name) +
    xlab("$S_L$") +
    ylab("$\\overline{\\text{chrF}_2}$")
  tex_file <- "chrf_paraphrase_detection_violin_joint_decision.tex"
  tikz(tex_file,
    width = 18, height = 8, standAlone = TRUE, engine = "luatex",
    packages = paste0(getOption("tikzLatexPackages"), "\\usepackage{amsmath}\n")
  )
  print(g)
  dev.off()
  post_process(tex_file)
  # plot all results
  collection <- cbind(deep_all, shallow[c("Source", "Target")])
  tex_file <- "chrf_paraphrase_detection_all.tex"
  g <- ggplot(collection, aes(x = Source, y = Target)) +
    geom_pointdensity(aes(x = Source, y = Target), adjust = 0.1) +
    theme_bw() +
    theme(
      text = element_text(size = 18),
      strip.background = element_blank(),
      legend.position = "bottom",
      legend.key.width = unit(6, "cm"),
      strip.text = element_text(face = "bold"),
      panel.grid = element_line(size = 1),
      axis.ticks.length = unit(.125, "cm"),
      plot.title = element_text(hjust = 0.5),
      axis.text = element_text(size = 13),
      ## axis.text.x = element_text(angle=45, vjust=0.6)
    ) +
    scale_color_gradientn(
      colours = tim.colors(24),
      name = "Point Density"
    ) +
    scale_x_continuous(breaks = c(0.25, 0.50, 0.75)) +
    scale_y_continuous(breaks = c(0.25, 0.50, 0.75)) +
    facet_nested(model_name + data_name ~ Type + Discrete) +
    guides(colour = guide_colourbar(
      title.position = "left", title.hjust = 0.5,
      title.vjust = 0.9
    )) +
    ylab(paste0("Target", " $\\overline{\\text{chrF}_2}$ [en]", "\n")) +
    xlab(paste0("\n", "Source", " $\\overline{\\text{chrF}_2}$ [de]"))
  # print to file
  tikz(tex_file,
    width = 26, height = 11, standAlone = TRUE, engine = "luatex",
    packages = paste0(getOption("tikzLatexPackages"), "\\usepackage{amsmath}\n")
  )
  print(grid.arrange(g))
  dev.off()
  post_process(tex_file)
  # plot compressed results
  shallow <- shallow[-c(which(names(shallow) == "Type"))]
  collection <- cbind(shallow, deep_compressed[-c(which(names(deep_compressed)
  %in% c("model_name", "data_name")))])
  tex_file <- "chrf_paraphrase_detection_joint_decision.tex"
  g <- ggplot(collection, aes(x = Source, y = Target)) +
    geom_pointdensity(aes(x = Source, y = Target), adjust = 0.1) +
    theme_bw() +
    theme(
      text = element_text(size = 18),
      strip.background = element_blank(),
      strip.text.x = element_text(margin = margin(0.1, 0, 0.34, 0, "cm")),
      legend.position = "bottom",
      legend.key.width = unit(6, "cm"),
      strip.text = element_text(face = "bold"),
      panel.grid = element_line(size = 1),
      axis.ticks.length = unit(.125, "cm"),
      plot.title = element_text(hjust = 0.5),
      axis.text = element_text(size = 13),
      ## axis.text.x = element_text(angle=45, vjust=0.6)
    ) +
    facet_nested(data_name ~ model_name + Label) +
    scale_color_gradientn(
      colours = tim.colors(24),
      name = "Point Density"
    ) +
    scale_x_continuous(breaks = c(0.25, 0.50, 0.75)) +
    scale_y_continuous(breaks = c(0.25, 0.50, 0.75)) +
    guides(colour = guide_colourbar(
      title.position = "left", title.hjust = 0.5,
      title.vjust = 0.9
    )) +
    ylab(paste0("Target", " $\\overline{\\text{chrF}_2}$ [en]", "\n")) +
    xlab(paste0("\n", "Source", " $\\overline{\\text{chrF}_2}$ [de]"))
  tikz(tex_file,
    width = 20, height = 7, standAlone = TRUE, engine = "luatex",
    packages = paste0(getOption("tikzLatexPackages"), "\\usepackage{amsmath}\n")
  )
  print(grid.arrange(g))
  dev.off()
  post_process(tex_file)
}

plot_model_evolutions <- function() {
  # get list of all files
  train_files <- Sys.glob("./models/transformer*/train_inner/*.csv")
  valid_files <- Sys.glob("./models/transformer*/valid/*.csv")
  if (length(train_files) != 1 || length(valid_files) != 1) {
    stop("Only two csv files can be processed for NMT evolution")
  }
  # plot for translation evolution
  train <- read.csv(train_files, stringsAsFactors = FALSE)
  valid <- read.csv(valid_files, stringsAsFactors = FALSE)
  train$type <- "Train"
  valid$type <- "Validation"
  collection <- rbind(train[, c("steps", "type", "loss")], valid[, c("steps", "type", "loss")])
  stop_point <- valid[which(valid[, "loss"] == min(valid[, "loss"])), "steps"]
  # plot object
  g <- ggplot(collection, aes(x = steps, y = loss)) +
    geom_line(aes(color = type), size = 1, alpha = 0.9) +
    geom_vline(aes(
      xintercept = stop_point, color = "Best Checkpoint",
      linetype = "Best Checkpoint"
    ),
    linetype = "dashed", alpha = 0.8, show.legend = FALSE
    ) +
    theme_bw() +
    ## ggtitle("Scaling NMT WMT16 Transformer Training") +
    scale_color_manual(
      values = c(
        "Train" = "red",
        "Validation" = "blue",
        "Best Checkpoint" = "black"
      ),
      breaks = c(
        "Train", "Validation",
        "Best Checkpoint"
      )
    ) +
    theme(
      text = element_text(size = 14),
      strip.background = element_blank(),
      legend.title = element_blank(),
      legend.position = c(0.88, 0.85),
      legend.background = element_blank(),
      legend.key = element_rect(fill = NA),
      legend.key.width = unit(0.8, "cm"),
      strip.text = element_text(face = "bold"),
      panel.grid = element_line(size = 1),
      axis.ticks.length = unit(.125, "cm"),
      plot.title = element_text(hjust = 0.5, size = 14),
      axis.text = element_text(size = 12),
      axis.title.x = element_text(margin = margin(t = 10, r = 0, b = 0, l = 0)),
      axis.title.y = element_text(margin = margin(t = 0, r = 10, b = 0, l = 0))
    ) +
    scale_x_continuous(
      labels = function(x) paste0(x / 1000, "k"),
      n.breaks = 20
    ) +
    guides(colour = guide_legend(override.aes = list(linetype = c(
      "Train" = "solid",
      "Validation" = "solid",
      "Best Checkpoint" = "dashed"
    )))) +
    xlab("Training Steps") +
    ylab("Cross Entropy Loss")
  tex_file <- "transformer_nmt_evolution.tex"
  tikz(tex_file, width = 9, height = 3, standAlone = TRUE, engine = "luatex")
  print(g)
  dev.off()
  post_process(tex_file)
  # get list of all files
  train_files <- Sys.glob("./models/*pawsx*/train/*.csv")
  valid_files <- Sys.glob("./models/*pawsx*/valid/*.csv")
  if (length(train_files) != 3 || length(valid_files) != 3) {
    stop("Only six csv files can be processed for paraphrase detection evolution")
  }
  # plot for paraphrase detection evolution combined
  train_bert <- read.csv(grep("bert-base", train_files, value = TRUE),
    stringsAsFactors = FALSE
  )
  train_xlmr <- read.csv(grep("roberta-base", train_files, value = TRUE),
    stringsAsFactors = FALSE
  )
  train_xlmrl <- read.csv(grep("roberta-large", train_files, value = TRUE),
    stringsAsFactors = FALSE
  )
  train_bert$model <- "mBERT\\textsubscript{Base}"
  train_xlmr$model <- "XLM-R\\textsubscript{Base}"
  train_xlmrl$model <- "XLM-R\\textsubscript{Large}"
  train <- rbind(train_bert, train_xlmr, train_xlmrl)
  train <- train[, c("steps", "loss", "model")]
  train$type <- "Training Cross Entropy Loss"
  names(train) <- c("steps", "value", "model", "type")
  # validation dataframe
  valid_bert <- read.csv(grep("bert-base", valid_files, value = TRUE), stringsAsFactors = FALSE)
  valid_xlmr <- read.csv(grep("roberta-base", valid_files, value = TRUE), stringsAsFactors = FALSE)
  valid_xlmrl <- read.csv(grep("roberta-large", valid_files, value = TRUE), stringsAsFactors = FALSE)
  valid_bert$model <- "mBERT\\textsubscript{Base}"
  valid_xlmr$model <- "XLM-R\\textsubscript{Base}"
  valid_xlmrl$model <- "XLM-R\\textsubscript{Large}"
  valid <- rbind(valid_bert, valid_xlmr, valid_xlmrl)
  valid <- valid[, c("steps", "model", "eval_acc")]
  valid$type <- "Validation Accuracy"
  names(valid) <- c("steps", "model", "value", "type")
  # combine dataframes
  collection <- rbind(train, valid)
  bert <- subset(valid, model == "mBERT\\textsubscript{Base}")
  bert_max <- bert[which.max(bert$value), 1]
  xlmr <- subset(valid, model == "XLM-R\\textsubscript{Base}")
  xlmr_max <- xlmr[which.max(xlmr$value), 1]
  xlmr_l <- subset(valid, model == "XLM-R\\textsubscript{Large}")
  xlmr_l_max <- xlmr_l[which.max(xlmr_l$value), 1]
  # plot object
  g <- ggplot(data = collection, aes(x = steps, y = value)) +
    geom_line(aes(color = model), size = 0.7, alpha = 0.8) +
    geom_vline(aes(
      xintercept = bert_max, color = "mBERT\\textsubscript{Base} Best Checkpoint",
      linetype = "Best Checkpoint_1"
    ),
    linetype = "dotted", alpha = 0.8, size = 1.5, show.legend = FALSE
    ) +
    geom_vline(aes(
      xintercept = xlmr_max, color = "XLM-R\\textsubscript{Base} Best Checkpoint",
      linetype = "Best Checkpoint_2"
    ),
    linetype = "dotdash", alpha = 0.8, size = 1, show.legend = FALSE
    ) +
    geom_vline(aes(
      xintercept = xlmr_l_max, color = "XLM-R\\textsubscript{Large} Best Checkpoint",
      linetype = "Best Checkpoint_3"
    ),
    linetype = "dashed", alpha = 0.8, size = 1, show.legend = FALSE
    ) +
    theme_bw() +
    ## ggtitle("Paraphrase Detection Model Training") +
    scale_color_manual(values = c(
      "mBERT\\textsubscript{Base}" = "red",
      "XLM-R\\textsubscript{Base}" = "blue",
      "XLM-R\\textsubscript{Large}" = "darkorange",
      "mBERT\\textsubscript{Base} Best Checkpoint" = "black",
      "XLM-R\\textsubscript{Base} Best Checkpoint" = "black",
      "XLM-R\\textsubscript{Large} Best Checkpoint" = "black"
    )) +
    theme(
      text = element_text(size = 19),
      strip.background = element_blank(),
      legend.title = element_blank(),
      legend.position = "bottom",
      legend.background = element_blank(),
      legend.key = element_rect(fill = NA),
      legend.key.width = unit(0.8, "cm"),
      strip.text = element_text(face = "bold", size = 18),
      panel.grid = element_line(size = 1),
      axis.ticks.length = unit(.125, "cm"),
      axis.title.x = element_text(margin = margin(t = 10, r = 0, b = 0, l = 0)),
      plot.title = element_text(hjust = 0.5, size = 14),
      axis.text = element_text(size = 16)
    ) +
    scale_x_continuous(
      labels = function(x) paste0(x / 1000, "k"),
      n.breaks = 8
    ) +
    facet_wrap(~type, scales = "free_y") +
    guides(colour = guide_legend(override.aes = list(linetype = c(
      "solid", "dotted",
      "solid", "dotdash",
      "solid", "dashed"
    ), size = 2))) +
    xlab("Training Steps") +
    ylab("")
  tex_file <- "paraphrase_detection_models_evolution.tex"
  tikz(tex_file, width = 12, height = 5, standAlone = TRUE, engine = "luatex")
  print(g)
  dev.off()
  post_process(tex_file)
}

# parse command-line arguments
parser <- OptionParser()
parser <- add_option(parser, c("-s", "--shallow-metrics"),
  action = "store_true",
  default = FALSE,
  help = "Flag for plotting shallow metrics [default: %default]"
)
parser <- add_option(parser, c("-p", "--paraphrase-detector-outputs"),
  action = "store_true", default = FALSE,
  help = "Flag for plotting paraphrase detector outputs [default: %default]"
)
parser <- add_option(parser, c("-m", "--mixed"),
  action = "store_true", default = FALSE,
  help = "Flag for plotting a mix of shallow and deep metrics [default: %default]"
)
parser <- add_option(parser, c("-e", "--evolutions"),
  action = "store_true", default = FALSE,
  help = "Flag for plotting all model evolutions [default: %default]"
)
parser <- add_option(parser, c("-j", "--json-glob"),
  type = "character",
  default = "./predictions/*/*.json",
  help = "Glob for finding input jsons [default: %default]"
)
args <- parse_args(parser)
if (args$s) {
  plot_shallow_metrics(args$j)
} else if (args$p) {
  plot_paraphrase_detector_outputs(args$j)
} else if (args$m) {
  plot_shallow_deep_correlations(args$j)
} else if (args$e) {
  plot_model_evolutions()
}
