% Matlab program to read a capture
% generated by capture.c
function capture = read_capture(fname)
%
% returns a structure with these components
%    data - sensor data
%    tdata - timing data - records end of scan
%      tdata(1,:) seconds since start of epoch - integer
%      tdata(2,:) nanoseconds since start of second - integer
%      tdata(3,:) combination of seconds/nanoseconds - float
%    wakeup_data: timing data - records beginning of scan
%      wakeup_data(1,:) seconds since start of epoch - integer
%      wakeup_data(2,:) nanoseconds since start of second - integer
%      wakeup_data(3,:) combination of seconds/nanoseconds - float
%    fname - file name where the data was read from
%    elem_size - size of the sensor data, in bytes
%    no_samples - number of samples
%    update_rate - update rate in microseconds
%    map - structure holding information from the
%          EtherCAT channel mapping 
%   
%     map.channel: channel number
%    map.assigned: whether assigned/not assigned
%    map.position: position in the bus
%   map.vendor_id:
%map.product_code:
%       map.index:
%    map.subindex:
%  map.bit_length:
%      map.offset:
%map.bit_position:
%       map.alias:

capture.data = [];
capture.tdata = [];
file = fopen(fname,'r');
checks.header = 'ETHERCAT CAPTURE FILE v1.3';
checks.tail = 'END OF CAPTURE FILE';
checks.extra_header = 'TIME DATA';
checks.wakeup_header = 'WAKEUP TIME DATA';
checks.extra_tail = 'END OF TIME DATA';
checks.header_read = fread(file, length(checks.header));
if (strcmp(char(checks.header_read'),checks.header))
    disp('header okay');
else
    disp('header not okay');
    fclose(file);
    return
end
buflen = fread(file, 1, 'int32');
buffer = fread(file, buflen, 'schar');
disp(char(buffer'));
capture.fname = fname;
capture.header = checks.header;
capture.elem_size =         fread(file, 1, 'int32');
capture.no_samples =        fread(file, 1, 'uint32');
capture.update_rate =       fread(file, 1, 'int32');
checks.mapsize =           fread(file, 1, 'int32');
capture.map.channel =       fread(file, 1, 'uint8');
capture.map.assigned =      fread(file, 1, 'uint8');
capture.map.position =      fread(file, 1, 'uint16');
capture.map.vendor_id =     fread(file, 1, 'uint32');
capture.map.product_code =  fread(file, 1, 'uint32');
capture.map.index =         fread(file, 1, 'uint16');
capture.map.subindex =      fread(file, 1, 'uint8');
capture.map.bit_length =    fread(file, 1, 'uint8');
capture.map.offset =        fread(file, 1, 'uint32');
capture.map.bit_position =  fread(file, 1, 'uint32');
capture.map.alias =         fread(file, 1, 'uint16');
checks.mapendcheck =       fread(file, 1, 'uint32');
if (checks.mapendcheck == checks.mapsize)
  disp('end check okay');
else
  disp('end check NOT okay');
end
type = 'int32';
switch capture.elem_size
    case 2
        type = 'int16';
    case 4
        type = 'int32';
    case 1
        type = 'int8';
    otherwise
        disp(sprintf('unexpected element size %d',capture.elem_size));
        return
end
capture.data = fread(file, capture.no_samples, type);
checks.tail_read = fread(file, length(checks.tail),'schar');
if (strcmp(char(checks.tail_read'), checks.tail))
    disp('tail okay');
else
    disp('tail not okay');
end

fclose(file);
return
