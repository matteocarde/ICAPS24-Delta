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
enhsp = readtable("enhsp.csv", opts);

enhsp.Result = enhsp.Time;
enhsp.Result(enhsp.Time ~= "TO" & enhsp.Time ~= "UNSAT" & enhsp.Time ~= "") = "FOUND";
enhsp.Result(enhsp.Time == "") = "TO";
enhsp.Time(enhsp.Result == "TO") = "60000";
enhsp.Time = str2double(enhsp.Time);

upm = readtable("upm.csv");
upm.CPU_Time(upm.Risolto == "false") = 60;
upm.CPU_Time(upm.CPU_Time > 60) = 60;

%% Plot
experiments = ["Baxter", "Descent", "HVAC", "Linear-Car", "Linear-Car-2", "Linear-Generator", "Solar-Rover"];
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
            filter =  enhsp.Experiment == experiment & enhsp.Type == type & enhsp.Delta == delta & (enhsp.Result == "FOUND");
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


t = tiledlayout(length(experiments),2,'TileSpacing','Compact','Padding','Compact');
f = figure(1);
f.Position = [100 100 1600 1000];

for i=1:length(experiments)
    experiment = string(experiments(i));
    
    nexttile
    x = deltas;
    filter = T.Domain == experiment & T.Metric == "Time";
    timeDomain = table2array(T(filter & T.Type == "DOMAIN", 4:10));
    timePlanning = table2array(T(filter & T.Type == "PLAN", 4:10));
    timeSimu = table2array(T(filter & T.Type == "SIMU", 4:10));
    timeUPM = table2array(T(filter & T.Type == "DOMAIN", 11:17));
    time = str2double([timePlanning' timeSimu' timeDomain' timeUPM']);
    
    semilogx(x,time,"-o",'LineWidth',2);
    grid on;
    box on;
    xticks(deltas);
    xlim([0 100]);
    ylabel("Planning Time");
    xlabel("Delta");
    yticks([0 20 40 60])
    set(gca,'Yticklabel',get(gca,'Ytick')+"s");
    hold on;
    t = title(experiment+" Planning Time");
    set(t, 'FontSize', 14)
    ax = gca;
    ax.LineWidth = 1;

    %l = legend(["ENHSP \delta_p", "ENHSP \delta_e","ENHSP \delta_d", "UPM \delta_d"]);
    %set(l,'Position',[0.598928571428571 0.8375 0.144642857142857 0.0904761904761905]);
    
    nexttile
    filter = T.Domain == experiment & T.Metric == "Coverage";
    coverageDomain = table2array(T(filter & T.Type == "DOMAIN", 4:10));
    coveragePlanning = table2array(T(filter & T.Type == "PLAN", 4:10));
    coverageSimu = table2array(T(filter & T.Type == "SIMU", 4:10));
    coverageUPM = table2array(T(filter & T.Type == "DOMAIN", 11:17));
    
    coverage = str2double([coveragePlanning' coverageSimu' coverageDomain' coverageUPM']);
    hold on;
    ylim([0 120])
    yticks([0 25 50 75 100]);
    ylabel("Coverage");
    xlabel("Delta");
    bar(log10(deltas), coverage);
    set(gca,'Xtick',log10(deltas)); %// adjust manually; values in log scale
    set(gca,'Xticklabel',10.^get(gca,'Xtick'));
    set(gca,'Yticklabel',get(gca,'Ytick')+"%");
    
    grid on;
    box on;
    if i == 1
        l = legend(["ENHSP Planning", "ENHSP Execution","ENHSP Dynamic", "UPM Dynamic"], 'Orientation','horizontal','EdgeColor','none','Color','none');
        l.Layout.Tile = 'north';
        set(l, 'FontSize', 14)
    end
    t = title(experiment+" Coverage");
    set(t, 'FontSize', 14)
    ax = gca;
    ax.LineWidth = 1;
end

set(gcf,'DefaultLineLineWidth',2);
set(gcf,'color','w');
