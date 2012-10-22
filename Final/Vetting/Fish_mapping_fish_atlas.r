#Script for producing fish images for vetting..........C James and L. Hodgson

library(SDMTools); library(maptools)#load the necessary libraries
source('/home/jc148322/scripts/libraries/cool_functions.r')

image.dir = "/home/jc246980/NorthernOZFish/DistributionImages"
data.dir="/home/jc246980/Janet_Stein_data"
species.dir="/home/jc246980/NorthernOZFish/Data"
base.asc = read.asc.gz('/home/jc165798/Climate/CIAS/Australia/5km/baseline.76to05/base.asc.gz') #read in the base asc file
pos = read.csv('/home/jc165798/Climate/CIAS/Australia/5km/baseline.76to05/base.positions.csv',as.is=TRUE) #read in the position files

species = list.files(species.dir)
ala.data = "/home/jc214262/Refugia/Vert_data/ALA_Vertebrate_data"



###################################
#Bring in all the necessary information

#catchments = readShapePoly('/home/jc246980/Janet_Stein_data/Level2Catchments/NCBLevel2Drainage.shp') #read in your shapefile
#rivers = readShapeLines('/home/jc246980/Janet Stein data/Major_rivers/Major_rivers.shp')
#save(rivers,file=paste(data.dir,'rivers.Rdata',sep=''))
#save(catchments,file=paste(data.dir,'catchments.Rdata',sep=''))

load("/home/jc246980/Janet_Stein_data/Rivers.Rdata")
load("/home/jc246980/Janet_Stein_data/catchments.Rdata")

for (sp in 1:length(species)) { cat(species[sp],'\n')
      species.data = as.data.frame(read.csv(paste(species.dir,"/",species[sp],sep=""), header = T,sep = ",", fill = T))
      if(file.exists(paste(ala.data, '/',species[sp],sep=''))){
      species.data.ala = read.csv(paste(ala.data, '/',species[sp],sep=''))
      } else {
      species.data.ala=NULL
      }

      assign.list(min.lon,max.lon,min.lat,max.lat) %=% dynamic.zoom(rbind(species.data$LONGITUDE,species.data.ala$LONGDEC),rbind(species.data$LATITUDE,species.data.ala$LATDEC),padding.percent=10)
    
      setwd(image.dir)


## this creates the mini-australia, called �clip�
if (max.lat>=-18 & min.lat<=-34 |
                max.lon>=148 & min.lon<=120 ) {
                xlim=c(min(pos$lon),max(pos$lon));
                ylim=c(min(pos$lat),max(pos$lat))
         
}else{
                xlim=c(min.lon,max.lon);
                ylim=c(min.lat,max.lat)

      }

      png(paste(species[sp],'.png',sep=''),width=dim(base.asc)[1]*2+30, height=dim(base.asc)[1]*2+80, units='px', pointsize=20, bg='white')
                      par(mar=c(2,2,2,2),cex=1,oma=c(3,0,1,0))

                      mat = matrix(c( 2,3,3,3,
                                                                                      1,1,1,1,
                                                                                      1,1,1,1,
                                                                                      1,1,1,1),nr=4,nc=4,byrow=TRUE) #create a layout matrix for images
                      layout(mat) #call layout as defined above

                      image(base.asc, ann=FALSE,axes=FALSE,col='white',  xlim=xlim,ylim=ylim)
                      image(base.asc, ann=FALSE,axes=FALSE,col='grey', xlim=xlim,ylim=ylim,xpd=FALSE,add=TRUE)

                      plot(catchments, lwd=2, ann=FALSE,axes=FALSE, add=TRUE, col='grey93', lwd=1.5)
                      plot(rivers, lwd=2, ann=FALSE,axes=FALSE, add=TRUE, col='cornflowerblue')

                      points(species.data[,'LONGITUDE'],species.data[,'LATITUDE'],pch=16,cex=2)

                      if(file.exists(paste(ala.data, '/',species[sp],sep=''))){
                      points(species.data.ala[,'LONGDEC'],species.data.ala[,'LATDEC'],pch=16,cex=2, col='red')
                      }


                      assign.list(l,r,b,t) %=% par("usr")

                      image(base.asc,ann=FALSE,axes=FALSE,col='#E5E5E5', zlim=c(0,1))
                      image(clip.image(l,r,b,t),ann=FALSE,axes=FALSE, col="grey20",add=TRUE)


                      plot(1:20,axes=FALSE,ann=FALSE,type='n')
                      speciesname=gsub('_',' ',species[sp]);speciesname=gsub('.csv',' ',speciesname)
                      text(7,15,speciesname,cex=4)
                           
                      legend(5,10, inset = c(0.4, 0.2),
                      legend = c("Northern Australia Fish Atlas", "ALA records"),
                      bty = "n", pch = c(19,19),           # bty = "n": no box
                      col = c(1,2), pt.cex = c(4, 4),
                      lty = c(-1,-1), cex=3)


      dev.off()
}
