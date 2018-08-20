function tem = res2tem(res)
    %% Convert resistance to temperature
    if numel(res)>1
        tem=zeros(size(res));
        for n=1:numel(res)
            tem(n)=convert_tem(res(n));
        end
        return;
    end
    if res>=1500 %main calibration branch, below ~5.6 K
        tem=log(polyval([0.00179188 -0.773105],res)).^-4;
    elseif res>950 %crude estimation between ~5.6 K and room tem, based on measurements at liquid helium, liquid nitrogen (1111.4 ohm) and room tem (1009.5 ohm)
        Tmax=300; %limit tem values to 300 K
        p=[0.000000002126673  -0.000007582360674   0.010163829259872  -3.448242363822648]; %coefficients from a 3rd order fit
        tem=min(Tmax,log(polyval(p,res)).^-4);
    else %invalid value
        tem=NaN; %output NaN
    end
end