function exit_r01
global r01

close_r01file;
if r01.file.open, return; end %closing failed

delete(gcf)

save_r01mem('custom');

add2log(0,['<<<< ',datestr(now,31), ' Session closed'],1);
add2log(0,' ',1);
