function y = normalise(x,min2zero)
    % All rows of x are normalised to be in (0,1) and to sum to 1
    for i = 1:size(x,1); 
        if min2zero
            x(i,:) = (x(i,:) - min(x(i,:))); 
        end
        x(i,:) = x(i,:)/(0.00000001+sum(x(i,:))); 
    end
    y = x;
end