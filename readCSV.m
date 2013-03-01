function result = readCSV(filename)

% data = readCSV('C:/hg/Master/code/python/201111face.com/result.csv');

i = 0;
filename = filename;
fid = fopen(filename, 'rt'); % ÉtÉ@ÉCÉãì«Ç›çûÇ›
keys = {};
values = {};
j = 0;
while feof(fid) == 0
    % tline = fgetl(fid);
    tline = fgetl(fid);
    parts = regexp(tline,',','split');
    i=i+1;
    if length(parts) == 7
        if(j == 0)
            keys = parts;
        else
            values{j} = containers.Map(keys, parts);
        end
        j = j+1;
    end
end
fclose(fid);

result = {};

for k=1:400
    faces = {};
    for l=1:length(values)
        val = values{l};
        index = round(str2double(val('index')));
        if(index == k)
            faces{length(faces)+1} = val;
        end
    end
    result{length(result)+1} = faces;
end
