import { Content, Page } from '@backstage/core-components';
import { HomePageSearchBar } from '@backstage/plugin-search';
import { SearchContextProvider } from '@backstage/plugin-search-react';
import { Grid, makeStyles } from '@material-ui/core';

import {
  HomePageToolkit,
  HomePageCompanyLogo,
  HomePageStarredEntities,
  TemplateBackstageLogoIcon,
} from '@backstage/plugin-home';

// Import the logo from public directory with correct base path
const logoUrl = '/backstage/android-chrome-192x192.png';

const useStyles = makeStyles(theme => ({
  searchBar: {
    display: 'flex',
    maxWidth: '60vw',
    backgroundColor: theme.palette.background.paper,
    boxShadow: theme.shadows[1],
    padding: '8px 0',
    borderRadius: '50px',
    margin: 'auto',
  },
}));

const useLogoStyles = makeStyles(theme => ({
  container: {
    margin: theme.spacing(5, 0),
  },
  svg: {
    width: 'auto',
    height: 100,
  },
  path: {
    fill: '#00568c',
  },
  customLogo: {
    width: '120px',
    height: 'auto',
    maxWidth: '100%',
    display: 'block',
    margin: '0 auto',
  },
}));

export const CustomHomepage = () => {
  const classes = useStyles();
  const { container, customLogo } = useLogoStyles();

  return (
    <SearchContextProvider>
      <Page themeId="home">
        <Content>
          <Grid container justifyContent="center" spacing={6}>
            {/* Company Logo */}
            <Grid container item xs={12} justifyContent="center">
              <div className={container}>
                <img 
                  src={logoUrl} 
                  alt="Company Logo" 
                  className={customLogo}
                />
              </div>
            </Grid>
            <Grid container item xs={12} alignItems="center" direction="row">
              <HomePageSearchBar classes={{ root: classes.searchBar }} placeholder="Search" />
            </Grid>
            <Grid container item xs={12}>
              <Grid item xs={12} md={6}>
                <HomePageStarredEntities />
              </Grid>
              <Grid item xs={12} md={6}>
                <HomePageToolkit
                  title="Quick Links"
                  tools={[
                    {
                      url: '/catalog',
                      label: 'Catalog',
                      icon: <TemplateBackstageLogoIcon/>,
                    },
                    {
                      url: '/docs',
                      label: 'Tech Docs',
                      icon: <TemplateBackstageLogoIcon />,
                    },
                  ]}
                />
              </Grid>
            </Grid>
          </Grid>
        </Content>
      </Page>
    </SearchContextProvider>
  );
};
