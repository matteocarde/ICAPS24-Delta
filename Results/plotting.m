%% Clear
close all; clear all; clc;

%% Load data
opts = delimitedTextImportOptions("NumVariables", 12);

% Specify range and delimiter
opts.DataLines = [2, Inf];
opts.Delimiter = ",";

% Specify column names and types
opts.VariableNames = ["Experiment", "Problem", "Type", "Delta", "Time", "PlanLength", "PlanningTime", "HeuristicTime", "SearchTime", "ExpandedNodes", "StatesEvaluated", "PlanDuration"];
opts.VariableTypes = ["categorical", "categorical", "categorical", "double", "string", "double", "double", "double", "double", "double", "double", "double"];

% Specify file level properties
opts.ExtraColumnsRule = "ignore";
opts.EmptyLineRule = "read";

% Specify variable properties
opts = setvaropts(opts, "Time", "WhitespaceRule", "preserve");
opts = setvaropts(opts, ["Experiment", "Problem", "Type", "Time"], "EmptyFieldRule", "auto");

% Import the data
enhsp = readtable("enhsp-hmrp.csv", opts);

enhsp.Result = enhsp.Time;
enhsp.Result(enhsp.Time ~= "TO" & enhsp.Time ~= "UNSAT" & enhsp.Time ~= "") = "FOUND";
enhsp.Result(enhsp.Time == "") = "UNSAT";
enhsp.Time(enhsp.Result == "TO") = "60000";
enhsp.Time = str2double(enhsp.Time);

upm = readtable("upm.csv");
upm.CPU_Time(upm.Risolto == "false") = "300";

%% Plot
experiments = unique(enhsp.Experiment);
types = unique(enhsp.Type);
deltas = unique(enhsp.Delta);
T = [];

for i=1:length(experiments)
    experiment = string(experiments(i));
    for t=1:length(types)
        type = string(types(t));
        row = [experiment, type, "Time"];
        for d=1:length(deltas)
            delta = deltas(d);
            filter = enhsp.Experiment == experiment & enhsp.Type == type & enhsp.Delta == delta & (enhsp.Result == "FOUND" | enhsp.Result == "TO");
            time = mean(enhsp.Time(filter), "omitnan")/1000;
            row = [row time];
        end
        for d=1:length(deltas)
            delta = deltas(d);
            filter = upm.Dominio == experiment & type == "DOMAIN" & upm.Delta == delta;
            time = mean(upm.CPU_Time(filter), "omitnan");
            row = [row time];
        end
        T = [T;row];
        row = [experiment, type, "Coverage"];
        for d=1:length(deltas)
            delta = deltas(d);
            total = enhsp.Experiment == experiment & enhsp.Type == type & enhsp.Delta == delta;
            filter =  enhsp.Experiment == experiment & enhsp.Type == type & enhsp.Delta == delta & (enhsp.Result == "FOUND" | enhsp.Result == "TO");
            solved = sum(filter)/sum(total)*100;
            row = [row solved];
        end
        for d=1:length(deltas)
            delta = deltas(d);
            total = upm.Dominio == experiment & type == "DOMAIN" & upm.Delta == delta;
            filter = upm.Dominio == experiment & type == "DOMAIN" & upm.Delta == delta & upm.Risolto == "true";
            solved = sum(filter)/sum(total)*100;
            row = [row solved];
        end
        T = [T;row];
    end
end

T= array2table(T,'VariableNames',{'Domain','Type','Metric','ENHSP1','ENHSP2','ENHSP3','ENHSP5','ENHSP10','ENHSP50','ENHSP100','UPM1','UPM2','UPM3','UPM5','UPM10','UPM50','UPM100'})

for i=1:1%length(experiments)
    figure(i);
    experiment = string(experiments(i));
    
    t = tiledlayout(2,1,'TileSpacing','Compact','Padding','Compact');
    nexttile
    x = deltas;
    filter = T.Domain == experiment & T.Metric == "Time";
    timeDomain = table2array(T(filter & T.Type == "DOMAIN", 4:10));
    timePlanning = table2array(T(filter & T.Type == "PLAN", 4:10));
    timeSimu = table2array(T(filter & T.Type == "SIMU", 4:10));
    time = str2double([timeDomain' timePlanning' timeSimu']);
    
    semilogx(x,time,"-o",'LineWidth',2);
    grid on;
    xticks(deltas);
    hold on;
    title(experiment);

    l = legend(["Dynamic", "Planning", "Execution"]);
    %set(l,'Position',[0.598928571428571 0.8375 0.144642857142857 0.0904761904761905]);
    
    nexttile
    filter = T.Domain == experiment & T.Metric == "Coverage";
    coverageDomain = table2array(T(filter & T.Type == "DOMAIN", 4:10));
    coveragePlanning = table2array(T(filter & T.Type == "PLAN", 4:10));
    coverageSimu = table2array(T(filter & T.Type == "SIMU", 4:10));
    
    coverage = str2double([coverageDomain' coveragePlanning' coverageSimu']);
    hold on;
    ylim([0 120])
    yticks([0 25 50 75 100]);
    xticks(deltas);
    hBar = bar(log10(deltas), coverage);
    set(gca,'Xtick',-3:1); %// adjust manually; values in log scale
    set(gca,'Xticklabel',10.^get(gca,'Xtick'));
    
    grid on;
    l = legend(["Dynamic", "Planning", "Execution"]);
    %set(l,'Position',[0.598928571428571 0.8375 0.144642857142857 0.0904761904761905]);
end