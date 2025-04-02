function r01logo
global r01

screen = get(0,'screensize');
swidth  = screen(3);
sheight = screen(4);

im = imread('r01logo.jpg');

iwidth  = size(im,2) / 2;
iheight = size(im,1) / 2;

pos = [(swidth-iwidth)/2 (sheight-iheight)/2 iwidth iheight];

r01.gui.fig_logo = figure('visible','on','menubar','none','paperpositionmode','auto','numbertitle','off','resize','off','position',pos,'name',['About ',r01.intern.name]);

image(im);
set(gca,'visible','off','Position',[0 0 1 1]);

text(30,90, [r01.intern.versiontxt,'  (',r01.intern.version_datestr,')'],'units','pixel','horizontalalignment','left','fontsize',14,'color',[.1 .1 .1]);
text(30,70, 'Code by Patrick King','units','pixel','horizontalalignment','left','fontsize',8,'color',[.1 .1 .1]);


end

