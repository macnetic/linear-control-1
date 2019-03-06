function T = preprocess(T)
% Assumes there is a timetag row in table T called 't'

% Remove rows with missing data
T = rmmissing(T);

% Remove rows where the time does not appear in order
i = 2;
while i < height(T)
    isBetween = (T.t(i-1) < T.t(i)) && (T.t(i) < T.t(i+1));
    if ~isBetween
        T(i,:) = [];
    end
    i = i+1;
end
end
